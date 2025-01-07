#!/bin/sh

# Run as sudo su

set -xe

echo "Set password as ratbatcat@2025"
adduser backup-user

echo "Set password as secretadmin@2025"
adduser notanadmin

usermod -aG sudo backup-user

apt update -y

apt install git vim python3-pip python3.10-venv openssh-server

mkdir .virtualenvs
cd .virtualenvs

python3 -m venv rfid_venv
source rfid_venv/bin/activate

cd ..

mkdir outpass

chown root:root outpass
chmod 700 outpass

cd outpass
mkdir rfid
cd rfid

echo "certifi==2024.2.2
charset-normalizer==3.3.2
evdev==1.7.0
idna==3.6
playsound==1.3.0
requests==2.31.0
urllib3==2.2.1" > requirements.txt

pip3 install -r requirements.txt

echo "# sudo evtest
# sudo chown <user> /dev/input/<event>

import evdev
from evdev import categorize, ecodes
import requests
from datetime import datetime
from playsound import playsound
import threading


def play_sound(path):
	playsound(path)

def log_errors(response,tag):
    timestamp = datetime.now()
    print(f\"{timestamp} - Error: {response} for {tag}\")
   # with open('error_log.txt', \"a\") as f:
    #    timestamp = datetime.now()
     #   f.write(f\"{timestamp} - Error: {response} for {tag}\n\")

class Device():
    name = 'RFID Reader RFID Reader'

    @classmethod
    def list(cls, show_all=False):
        # list the available devices
        devices = [evdev.InputDevice(fn) for fn in evdev.list_devices()]
        if show_all:
            for device in devices:
                print(\"event: \" + device.fn, \"name: \" + device.name, \"hardware: \" + device.phys)
        return devices

    @classmethod
    def connect(cls):
        # connect to device if available
        try:
            device = [dev for dev in cls.list() if cls.name in dev.name][0]
            device = evdev.InputDevice(device.path)
            return device
        except IndexError:
            print(datetime.now(), \"Device not found.\n - Check if it is properly connected. \n - Check permission of /dev/input/ (see README.md)\", flush=True)
            exit()

    @classmethod
    def run(cls):
        device = cls.connect()
        container = []
        try:
            device.grab()

            # bind the device to the script
            print(datetime.now(),\"RFID scanner is ready....\", flush=True)
            #print(\"Press Control + c to quit.\", flush=True)
            for event in device.read_loop():
                # enter into an endeless read-loop
                if event.type == ecodes.EV_KEY and event.value == 1:
                    digit = evdev.ecodes.KEY[event.code]
                    if digit == 'KEY_ENTER':
                        
                        tag = \"\".join(i.strip('KEY_') for i in container)
                        tag = tag.lstrip('0')
                        print(datetime.now(), \"Tag: \" + tag, flush=True)
                        container = []

                        url = \"http://192.168.136.216/server/populate/rfid/recognition\"
                        
                        data = {\"rfid\": tag}
                        response = requests.post(url,json=data)
                        if response.status_code == 200:
                             print(f\"{datetime.now()} Success!!\", flush=True)
                             sound_thread = threading.Thread(target=play_sound,args =(\"/home/user07/Desktop/outpass/rfid/success_effect.wav\",))
                             sound_thread.start()
                   
                        elif response.status_code == 404:
                             sound_thread = threading.Thread(target=play_sound,args =(\"/home/user07/Desktop/outpass/rfid/error_effect.mp3\",))
                             sound_thread.start()
                             log_errors(response.status_code,tag)
                         
                              
                        elif response.status_code == 500:
                             log_errors(response.status_code,tag)
                             print(f\"{datetime.now()} Student {tag} attempted scanning without creating an Outpass \", flush=True)
                             try:
                                 sound_thread = threading.Thread(target=play_sound,args= (\"/home/user07/effect/among.mp3\",))
                                 sound_thread.start()
                             except:
                                 print(f\"{datetime.now()} sound not played\")
                               
                        else:
                             log_errors(response.json,tag)
                             print(f\"{datetime.now()} {response.json}\", flush=True)
                    else:
                        container.append(digit)
                # print(event.type, event.code, event.value)
                # print(categorize(event))


        except Exception as e:
            print(f\"{datetime.now()} An unexpected error occurred: {e} Quitting.\")

Device.run()" > rfid.py

echo "#!/bin/sh
/home/iiit-kottayam/.virtualenvs/rfid_venv/bin/python /home/iiit-kottayam/outpass/rfid/rfid.py" > script.sh

chmod +x script.sh

systemctl enable ssh --now
systemctl start ssh

# Change port for ssh to 6999 in /etc/ssh/sshd_config
