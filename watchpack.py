import time
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler
import os
import logging
from systemd.journal import JournalHandler
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
log = logging.getLogger('watchpack.service')
log.addHandler(JournalHandler())
log.setLevel(logging.INFO)

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

def on_created(event):
    global suppress
    global ln
    suppress = True
    log.info(style.GREEN+f"{event.src_path} - New Message"+style.RESET)
    try:
        log.info(style.GREEN+"Capturing image..."+style.RESET)
        os.system('fswebcam -r 1920x1080 /home/pi/image_capture.jpg')
    except:
        log.info(style.RED+"Camera Error (404) - Make sure camera is connected and turned on"+style.RESET)
    try:
        log.info(style.GREEN+"Collecting GPS data..."+style.RESET)
        if ln[0]=="":
            log.info(style.RED+"GPS Error - Unable to collect GPS data(0)"+style.RESET)
    except:
        log.info(style.RED+"GPS Error - Unable to collect GPS data(1)"+style.RESET)
    try:
        log.info(style.GREEN+"Packaging Data..."+style.RESET)
        with open(str(event.src_path), 'r') as reader:
            message = reader.readlines()
        user = str(event.src_path)[str(event.src_path).rindex('/')+1:]
        log.info(style.GREEN+"USER: "+user+style.RESET)
        log.info(style.GREEN+"MESSAGE: "+str(message)[2:-4]+style.RESET)
        log.info(style.GREEN+"Creating directory..."+style.RESET)
        makepath='/home/pi/'+user
        os.system('mkdir -p \''+makepath+'\'')
        log.info(style.GREEN+"Dumping contents..."+style.RESET)
        with open(makepath+"/message.txt", "a") as messagefile:
            messagefile.write(str(message)[2:-4])
            for i in range(len(ln)):
                messagefile.write("\n"+ln[i])
        os.system('mv /home/pi/image_capture.jpg ''\''+makepath+'/image_capture.jpg\'')
        user_zip = [makepath]
        with zipfile.ZipFile(makepath+'.zip', 'w') as zipMe:        
          for file in user_zip:
            zipMe.write(file, compress_type=zipfile.ZIP_DEFLATED)
        log.info(style.GREEN+"Cleaning up..."+style.RESET)
        os.system('rm -r -f \''+makepath+'\'')
        os.system('rm -r -f \''+str(event.src_path)+'\'')
        log.info(style.GREEN+"DONE"+style.RESET)
        suppress = False
    except:
        suppress = False
        log.info(style.RED+"File write error"+style.RESET)

if __name__ == "__main__":
    logCounter=0
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
                                log.info(style.YELLOW+raw.strip('\n')+style.RESET)
                        elif len(raw) != 0 and not suppress:
                            if logCounter > 20:
                                log.info(style.YELLOW+raw.strip('\n')+style.RESET)
                                logCounter=0
                            else:
                                logCounter+=1
            except KeyboardInterrupt:
                my_observer.stop()
                my_observer.join()
            except Exception:
                continue
        except:
            continue