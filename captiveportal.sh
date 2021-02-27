#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RESET='\e[0m'
WHITEBLACK='\e[0;30;47m'

if [ "$EUID" -ne 0 ]
	then echo "${RESET}${RED}Must be root, run sudo -i before running this script.${RESET}"
	exit
fi

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Updating repositories${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get update -yqq
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Installing and configuring nginx${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get install nginx -yqq
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Setting up filesystem${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
mkdir -p /var/www/html/images
mkdir -p /var/www/html/passwords
mkdir -p /var/www/html/files
chmod 777 /var/www/html
chmod 777 /var/www/html/passwords
chmod 777 /var/www/html/images
chmod 777 /var/www/html/files
cp -u /home/pi/Captive-Portal/config_files/default_nginx /etc/nginx/sites-enabled/default
cp -u /home/pi/Captive-Portal/config_files/journald.conf /etc/systemd/journald.conf
cp -u /home/pi/Captive-Portal/php/index.php /var/www/html/index.php
cp -u /home/pi/Captive-Portal/php/download.php /var/www/html/download.php
cp -u /home/pi/Captive-Portal/php/submit.php /var/www/html/submit.php
cp -u /home/pi/Captive-Portal/images/Android.png /var/www/html/images/Android.png
cp -u /home/pi/Captive-Portal/images/spatiam.jpg /var/www/html/images/spatiam.jpg
cp -u /home/pi/Captive-Portal/php/submit.php /var/www/html/submit.php
cp -u /home/pi/Captive-Portal/ion/DTN.apk /var/www/html/files/DTN.apk
cp -u /home/pi/Captive-Portal/watchpack.py /var/www/html/watchpack.py
mv -u /home/pi/Captive-Portal/ion/ion-open-source-4.0.2.tar.gz /home/pi/ion-open-source-4.0.2.tar.gz
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring Python${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Installing dnsmasq${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get install dnsmasq -yqq
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring wlan0${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
cp -u /home/pi/Captive-Portal/config_files/dhcpcd.conf /etc/dhcpcd.conf
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring dnsmasq${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
cp -u /home/pi/Captive-Portal/config_files/dnsmasq.conf /etc/dnsmasq.conf
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring dnsmasq to start at boot${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
update-rc.d dnsmasq defaults
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Installing hostapd${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get install hostapd -yqq
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring hostapd${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
cp -u /home/pi/Captive-Portal/config_files/hostapd.conf /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Setting country code${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
iw reg set US
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring iptables${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Configuring hostapd to start at boot${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
systemctl unmask hostapd.service
systemctl enable hostapd.service
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Installing PHP7${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-curl php7.3-gd php7.3-curl php7.3-zip php7.3-xml -yqq > /dev/null
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Building watchpack service${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
sudo pip install Watchdog
sudo pip install systemd
apt-get install -y fswebcam
apt-get install -y zip unzip
set -o noclobber
filename='/lib/systemd/system/watchpack.service'
if [ -f $filename ]; then
    rm $filename
fi
touch $filename
cat >| /lib/systemd/system/watchpack.service <<"EOL"
[Unit]
Description=Watchdog Packaging Service
After=multi-user.target
[Service]
Type=simple
ExecStart=/usr/bin/python /var/www/html/watchpack.py
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
sudo chmod 644 /lib/systemd/system/watchpack.service
chmod +x /var/www/html/watchpack.py
sudo systemctl daemon-reload
sudo systemctl enable watchpack
sudo systemctl start watchpack
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Setting up GPS${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
apt-get install -y gpsd gpsd-clients python-gps
sudo systemctl stop gpsd.socket
sudo systemctl disable gpsd.socket
filename='/lib/systemd/system/gpsd.socket'
if [ -f $filename ]; then
    rm $filename
fi
touch $filename
cat >| /lib/systemd/system/gpsd.socket <<"EOL"
[Unit]
Description=GPS (Global Positioning System) Daemon Sockets
[Socket]
ListenStream=/var/run/gpsd.sock
ListenStream=[::1]:2947
ListenStream=0.0.0.0:2947
SocketMode=0600
[Install]
WantedBy=sockets.target
EOL
sudo killall gpsd
sudo gpsd /dev/ttyACM0 -F /var/run/gpsd.sock
sudo systemctl enable gpsd.socket
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Building Ion${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
tar -xvzf /home/pi/ion-open-source-4.0.2.tar.gz
(cd /home/pi/ion-open-source-4.0.2 && ./configure)
(cd /home/pi/ion-open-source-4.0.2 && make)
(cd /home/pi/ion-open-source-4.0.2 && sudo make install)
sudo ldconfig
rm -r -f /home/pi/ion-open-source-4.0.2.tar.gz
mkdir /home/pi/ion-open-source-4.0.2/dtn
mv -u /home/pi/Captive-Portal/config_files/mule.rc /home/pi/ion-open-source-4.0.2/dtn/mule.rc
killm
ionstart -I /home/pi/ion-open-source-4.0.2/dtn/mule.rc
ss -panu
ipcs
echo "${GREEN}DONE"

echo "${YELLOW}┌─────────────────────────────────────────"
echo "|${WHITEBLACK}Reoot required${RESET}${YELLOW}"
echo "└─────────────────────────────────────────${RESET}"
read -n 1 -s -r -p "${CYAN}Press any key to reboot${RESET}"
reboot