import time
import os
import logging
from systemd.journal import JournalHandler
import datetime
import serial
import threading
import subprocess, signal
import zipfile
import glob
import paho.mqtt.client as mqtt
import magic
import base64

dg = u'\N{DEGREE SIGN}'
raw=""
ln=["","","","","","",""]
suppress = False
log = logging.getLogger('ionlistener.service')
log.addHandler(JournalHandler())
log.setLevel(logging.INFO)
broker = "localhost"
client = mqtt.Client("ion-publisher")
client.connect(broker)

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

if __name__ == "__main__":
    os.system('export TERM=xterm')
    for i in range(20):
        print(style.YELLOW+"Starting ionlistener service in "+str(20-i)+"s"+style.RESET)
        time.sleep(1)
    os.system('ionstop')
    time.sleep(5)
    os.system('(cd /home/pi && sudo -u pi ionstart -I /home/pi/ion-open-source-4.0.2/dtn/mule.rc)')
    os.system('sudo chmod 777 /tmp/ion.sdrlog')
    os.system('sudo chmod 777 /tmp')
    os.system('sudo chmod o+rwx /tmp')
    os.system('ipcs')
    process = subprocess.Popen(['sudo', '-u', 'pi', 'bprecvfile','ipn:1.1', '1'], stdout=subprocess.PIPE)
    print(style.CYAN+"ION_BPRECVFILE STARTED"+style.RESET)
    if not os.path.exists('/home/pi/ion.log'):
        print(style.RED+"ERROR: ion.log not located at /home/pi"+style.RESET)
        quit()
    file_clear=open('/home/pi/ion.log',"r+")
    file_clear.truncate(0)
    file_clear.close()
    FO=open('/home/pi/ion.log', 'r')
    fileCounter=0
    while True:
        loglines=FO.readline()
        if loglines.find('created') >=0:
            time.sleep(2)
            recvfile=loglines.split(' ')[-3].strip(',').strip('\'')
            print(style.YELLOW+"RECEIVED:"+recvfile+style.RESET)
            full_filename=str('/home/pi/'+str(fileCounter))
            fileCounter+=1
            os.system('sudo mv '+recvfile+' '+full_filename)
            print(style.YELLOW+'CREATED '+full_filename+style.RESET)
            os.system('ls -l')
            ftype=str(magic.from_file(full_filename))
            print(style.YELLOW+"DETECTED FILE TYPE:"+ftype+style.RESET)
            if(ftype == "ASCII text"):
                with open(full_filename) as f:
                    true_output=f.readline().strip()
                suppress=True
                try:
                    authError=False
                    authType=true_output.split(' ')[-2]
                    print(style.WHITE+"authType:"+authType+style.RESET)
                    usnm=base64.b64decode(true_output.split(' ')[-1]).decode('UTF-8').split(':')[0]
                    print(style.WHITE+"usnm:"+usnm+style.RESET)
                    key=base64.b64decode(true_output.split(' ')[-1]).decode('UTF-8').split(':')[-1]
                    print(style.WHITE+"key:"+key+style.RESET)
                except:
                    print(style.RED+"Authentication Error"+style.RESET)
                    authError=True
                if(("@@download:" in true_output.split(' ')[0]) and (authType == "Basic") and (not authError) and (usnm == "spatiam") and (key == "spatiam")):
                    os.system('rm -r -f '+full_filename)
                    print(style.RED+"STOPPING bprecvfile process..."+style.RESET)
                    #process.send_signal(signal.SIGINT)
                    try:
                        return_ipn = str(int(true_output.split(' ')[0].split(":")[-1]))
                        print(style.CYAN+"Return ipn:"+return_ipn+".1"+style.RESET)
                        homepath='/home/pi/*.zip'
                        filenames = glob.glob(homepath)
                        for file in filenames:
                            if file == "/home/pi/download.zip":
                                filenames.remove(file)
                        print(filenames)
                        with zipfile.ZipFile('/home/pi/download.zip', 'w') as zipMe:
                            for file in filenames:
                                zipMe.write(file, compress_type=zipfile.ZIP_DEFLATED)
                        for file in filenames:
                            if file != "/home/pi/download.zip":
                                print('rm -r -f \"'+file+"\"")
                                os.system('rm -r -f \"'+file+"\"")
                        for i in range(10):
                            print(style.YELLOW+"bpsendfile to ipn:"+return_ipn+".1 in "+str(10-i)+"s"+style.RESET)
                            time.sleep(1)
                        FS=open('/home/pi/ion.log', 'r')
                        send_command = "sudo -u pi bpsendfile ipn:1.1 ipn:"+return_ipn+".1 /home/pi/download.zip"
                        print(style.GREEN+send_command+style.RESET)
                        os.system(send_command)
                        sentPackage=False
                        while not sentPackage:
                            rdr=FS.readline()
                            if rdr.find('bpsendfile sent') >=0:
                                sentPackage=True
                                print(style.GREEN+"SUCCESS"+style.RESET)
                        os.system('sudo mv /home/pi/download.zip /home/pi/archive/download.zip')
                    except:
                        print(style.RED+"FAILED TO PACKAGE ZIP"+style.RESET)
                    print(style.GREEN+"RESTARTING bprecvfile process..."+style.RESET)
                    time.sleep(10)
                    process = subprocess.Popen(['sudo', '-u', 'pi', 'bprecvfile','ipn:1.1', '1'], stdout=subprocess.PIPE)
                    print(style.CYAN+"ION_MESSAGE_LISTENER STARTED"+style.RESET)
                else:
                    process = subprocess.Popen(['sudo', '-u', 'pi', 'bprecvfile','ipn:1.1', '1'], stdout=subprocess.PIPE)
    rc = process.poll()