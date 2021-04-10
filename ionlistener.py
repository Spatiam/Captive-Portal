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
    lineCounter=0
    for i in range(20):
        log.info(style.YELLOW+"Starting ionlistener service in "+str(20-i)+"s"+style.RESET)
        time.sleep(1)
    os.system('killm')
    os.system('ionstart -I /home/pi/ion-open-source-4.0.2/dtn/mule.rc')
    process = subprocess.Popen(['bpsink','ipn:1.1'], stdout=subprocess.PIPE)
    log.info(style.CYAN+"ION_MESSAGE_LISTENER STARTED"+style.RESET)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            suppress=True
            if lineCounter == 2:
                lineCounter = 0
                true_output = output.decode('utf-8').strip()[1:-1]
                log.info(style.GREEN+"ION MESSAGE:"+true_output+style.RESET)
                if "download:" in true_output:
                  log.info(style.RED+"STOPPING bpsink process..."+style.RESET)
                  process.send_signal(signal.SIGINT)
                  try:
                    return_ipn = true_output.split(":")[-1]
                    homepath='/home/pi/*.zip'
                    filenames = glob.glob(homepath)
                    for file in filenames:
                      if file == "/home/pi/download.zip":
                        filenames.remove(file)
                    log.info(filenames)
                    with zipfile.ZipFile('/home/pi/download.zip', 'w') as zipMe:
                      for file in filenames:
                        zipMe.write(file, compress_type=zipfile.ZIP_DEFLATED)
                    for file in filenames:
                      if file != "/home/pi/download.zip":
                        os.system('rm -r -f '+file)
                    for i in range(10):
                        log.info(style.YELLOW+"bpsendfile to ipn:"+return_ipn+".1 in "+str(10-i)+"s"+style.RESET)
                        time.sleep(1)
                    send_command = "bpsendfile ipn:1.1 ipn:"+return_ipn+".1 /home/pi/download.zip"
                    log.info(style.GREEN+send_command+style.RESET)
                    os.system(send_command)
                  except:
                    log.info(style.RED+"FAILED TO PACKAGE ZIP"+style.RESET)
                  log.info(style.GREEN+"RESTARTING bpsink process..."+style.RESET)
                  process = subprocess.Popen(['bpsink','ipn:1.1'], stdout=subprocess.PIPE)
                  log.info(style.CYAN+"ION_MESSAGE_LISTENER STARTED"+style.RESET)
            if lineCounter == 1:
                try:
                    number = int(output.decode('utf-8').strip().split(" ")[-1].replace('.',''))
                    if number < 80:
                        lineCounter = 2
                    else:
                         log.info(style.GREEN+"RECEIVED PAYLOAD > 79"+style.RESET)
                except:
                    lineCounter = 0
            if output.decode('utf-8').strip() == "ION event: Payload delivered.":
                lineCounter = 1
    rc = process.poll()