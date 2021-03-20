import time
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler
import os
from systemd import journal
import datetime
import serial
import threading
import subprocess
import zipfile
import glob

dg = u'\N{DEGREE SIGN}'
raw=""
ln=["","","","","","",""]
suppress = False

class style():
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    UNDERLINE = '\033[4m'
    RESET = '\033[0m'

def parse(data):
  sdata = data.split(",")
  time = sdata[1][0:2] + ":" + sdata[1][2:4] + ":" + sdata[1][4:6]
  lat = decode(sdata[3])
  dirLat = sdata[4]
  lon = decode(sdata[5])
  dirLon = sdata[6]
  speed = sdata[7]
  date = sdata[9][2:4] + "/" + sdata[9][0:2] + "/" + sdata[9][4:6]
  latDD = DMStoDD(lat,dirLat)
  lonDD = DMStoDD(lon,dirLon)
  return latDD, lonDD, speed, date, time

def DMStoDD(coord,dir):
  coord = coord.replace(" ","")
  deg = coord[0:coord.index('deg')]
  min = coord[coord.index('deg')+3:coord.index('min')]
  if dir == 'N' or dir == 'E':
    mult = 1
  else:
    mult = -1
  return mult*(int(deg)+(float(min)/60))

def decode(coord):
  x = coord.split(".")
  head = x[0]
  tail = x[1]
  deg = head[0:-2]
  min = head[-2:]
  return deg + " deg " + min + "." + tail + " min"

def ion_message_listener():
    global suppress
    lineCounter=0
    time.sleep(60)
    os.system('killm')
    os.system('ionstart -I /home/pi/ion-open-source-4.0.2/dtn/mule.rc')
    process = subprocess.Popen(['bpsink','ipn:1.1'], stdout=subprocess.PIPE)
    journal.write("ION_MESSAGE_LISTENER STARTED")
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            suppress=True
            if lineCounter == 2:
                lineCounter = 0
                true_output = output.decode('utf-8').strip()[1:-1]
                journal.write(style.GREEN+"ION MESSAGE:"+true_output+style.RESET)
                if "download:" in true_output:
                  try:
                    return_ipn = true_output.split(":")[-1]
                    homepath='/home/pi/*.zip'
                    filenames = glob.glob(homepath)
                    for file in filenames:
                      if file == "/home/pi/download.zip":
                        filenames.remove(file)
                    journal.write(filenames)
                    with zipfile.ZipFile('/home/pi/download.zip', 'w') as zipMe:
                      for file in filenames:
                        zipMe.write(file, compress_type=zipfile.ZIP_DEFLATED)
                    for file in filenames:
                      if file != "/home/pi/download.zip":
                        os.system('rm -r -f '+file)
                    for i in range(10):
                        journal.write(style.YELLOW+"bpsendfile to ipn:"+return_ipn+".1 in "+str(10-i)+"s"+style.RESET)
                        time.sleep(1)
                    send_command = "bpsendfile ipn:1.1 ipn:"+return_ipn+".1 /home/pi/download.zip"
                    journal.write(style.GREEN+send_command+style.RESET)
                    os.system(send_command)
                  except:
                    journal.write(style.RED+"FAILED TO PACKAGE ZIP"+style.RESET)
            if lineCounter == 1:
                try:
                    number = int(output.decode('utf-8').strip().split(" ")[-1].replace('.',''))
                    if number < 80:
                        lineCounter = 2
                    else:
                         journal.write(style.GREEN+"RECEIVED PAYLOAD > 79"+style.RESET)
                except:
                    lineCounter = 0
            if output.decode('utf-8').strip() == "ION event: Payload delivered.":
                lineCounter = 1
            suppress=False
    rc = process.poll()
    return rc

def on_created(event):
    global suppress
    global ln
    suppress = True
    journal.write(style.GREEN+f"{event.src_path} - New Message"+style.RESET)
    try:
        journal.write(style.GREEN+"Capturing image..."+style.RESET)
        os.system('fswebcam -r 1920x1080 /home/pi/image_capture.jpg')
    except:
        journal.write(style.RED+"Camera Error (404) - Make sure camera is connected and turned on"+style.RESET)
    try:
        journal.write(style.GREEN+"Collecting GPS data..."+style.RESET)
        if ln[0]=="":
            journal.write(style.RED+"GPS Error - Unable to collect GPS data(0)"+style.RESET)
    except:
        journal.write(style.RED+"GPS Error - Unable to collect GPS data(1)"+style.RESET)
    try:
        journal.write(style.GREEN+"Packaging Data..."+style.RESET)
        with open(str(event.src_path), 'r') as reader:
            message = reader.readlines()
        user = str(event.src_path)[str(event.src_path).rindex('/')+1:]
        journal.write(style.GREEN+"USER: "+user+style.RESET)
        journal.write(style.GREEN+"MESSAGE: "+str(message)[2:-4]+style.RESET)
        journal.write(style.GREEN+"Creating directory..."+style.RESET)
        makepath='/home/pi/'+user
        os.system('mkdir -p \''+makepath+'\'')
        journal.write(style.GREEN+"Dumping contents..."+style.RESET)
        with open(makepath+"/message.txt", "a") as messagefile:
            messagefile.write(str(message)[2:-4])
            for i in range(len(ln)):
                messagefile.write("\n"+ln[i])
        os.system('mv /home/pi/image_capture.jpg ''\''+makepath+'/image_capture.jpg\'')
        user_zip = [makepath]
        with zipfile.ZipFile(makepath+'.zip', 'w') as zipMe:        
          for file in user_zip:
            zipMe.write(file, compress_type=zipfile.ZIP_DEFLATED)
        journal.write(style.GREEN+"Cleaning up..."+style.RESET)
        os.system('rm -r -f \''+makepath+'\'')
        os.system('rm -r -f \''+str(event.src_path)+'\'')
        journal.write(style.GREEN+"DONE"+style.RESET)
        suppress = False
    except:
        suppress = False
        journal.write(style.RED+"File write error"+style.RESET)

if __name__ == "__main__":
    ion_message_listener_thread = threading.Thread(target=ion_message_listener)
    ion_message_listener_thread.start()
    while(1):
        try:
            os.system('export TERM=xterm')
            patterns = "*"
            ignore_patterns = ""
            ignore_directories = False
            case_sensitive = True
            path = "/var/www/html/passwords"
            my_event_handler = PatternMatchingEventHandler(patterns, ignore_patterns, ignore_directories, case_sensitive)
            my_event_handler.on_created = on_created
            go_recursively = True
            my_observer = Observer()
            my_observer.schedule(my_event_handler, path, recursive=go_recursively)
            my_observer.start()
            try:
                with serial.Serial('/dev/ttyACM0', 115200, timeout=1) as ser:
                    while(1):
                        raw = ser.read(ser.in_waiting).decode('utf-8')
                        if raw[0:6] == "$GPRMC" and not "$GPVTG" in raw and raw.split(",")[2] != 'V':
                            latDD, lonDD, speed, date, time = parse(raw)
                            url = str("https://www.google.com/maps/place/"+str(f"{latDD:.6f}")+"+"+str(f"{lonDD:.6f}"))
                            os.system('clear')
                            ln[0]="*"*(len(url)+9)
                            ln[1]="* LATITUDE: "+str(f"{latDD:.6f}")+dg+" "*(6+len(url)-len(str(" LATITUDE: "+str(f"{latDD:.6f}"))))+"*"
                            ln[2]="* LONGITUDE: "+str(f"{lonDD:.6f}")+dg+" "*(6+len(url)-len(str(" LONGITUDE: "+str(f"{lonDD:.6f}"))))+"*"
                            ln[3]="* SPEED: "+str(f"{float(speed)*1.852:.6f}")+" kph"+" "*(7+len(url)-len(str(f"{float(speed)*1.852:.6f}")+" kph")-8)+"*"
                            ln[4]="* TIMESTAMP: "+date+" "+time+"GMT"+" "*(7+len(url)-len(str(" TIMESTAMP: "+date+" "+time+"GMT")))+"*"
                            ln[5]="* "+url+"      *"
                            ln[6]="*"*(len(url)+9)
                            if not suppress:
                                journal.write(style.YELLOW+raw.strip('\n')+style.RESET)
                        elif len(raw) != 0 and not suppress:
                            journal.write(style.YELLOW+raw.strip('\n')+style.RESET)
            except KeyboardInterrupt:
                my_observer.stop()
                my_observer.join()
            except Exception:
                continue
        except:
            continue