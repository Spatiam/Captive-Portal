#THIS IS CURRENTLY UNTESTED
import time
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler
import os
from systemd import journal
import datetime

#new message stored
def on_created(event):
    journal.write(f"{event.src_path} - New Message")
    #capture image
    try:
        journal.write("Capturing image...")
        os.system('fswebcam -r 1920x1080 /home/pi/image_capture.jpg')
    except:
        journal.write("Camera Error (404) - Make sure camera is connected and turned on")
    #read gps
    try:
        journal.write("Collecting GPS data...")
        #do gps serial commands here
    except:
        journal.write("GPS Error - Unable to collect GPS data")
    #bundle
    try:
        journal.write("Packaging Data...")
        #collect message data
        with open(str(event.src_path), 'r') as reader:
            message = reader.readlines()
        user = str(event.src_path)[str(event.src_path).rindex('/')+1:]
        journal.write("USER: "+user)
        journal.write("MESSAGE: "+str(message)[2:-4])
        #make a new directory for the user
        journal.write("Creating directory...")
        makepath='/home/pi/'+user
        os.system('mkdir -p \''+makepath+'\'')
        #dump contents
        journal.write("Dumping contents...")
        with open(makepath+"/message.txt", "a") as messagefile:
            messagefile.write(str(message)[2:-4])
        os.system('mv /home/pi/image_capture.jpg ''\''+makepath+'/image_capture.jpg\'')
        journal.write("Cleaning up...")
        os.system('rm \''+str(event.src_path)+'\'')
        #also dump GPS data and timestamp
        journal.write("DONE")
    except:
        journal.write("File write error")

def on_deleted(event):
    time.sleep(0)

def on_modified(event):
    time.sleep(0)

def on_moved(event):
    time.sleep(0)

if __name__ == "__main__":
    patterns = "*"
    ignore_patterns = ""
    ignore_directories = False
    case_sensitive = True
    my_event_handler = PatternMatchingEventHandler(patterns, ignore_patterns, ignore_directories, case_sensitive)
    my_event_handler.on_created = on_created
    my_event_handler.on_deleted = on_deleted
    my_event_handler.on_modified = on_modified
    my_event_handler.on_moved = on_moved
    path = "/var/www/html/passwords"
    go_recursively = True
    my_observer = Observer()
    my_observer.schedule(my_event_handler, path, recursive=go_recursively)
    my_observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        my_observer.stop()
        my_observer.join()