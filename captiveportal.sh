#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo "Must be root, run sudo -i before running this script."
	exit
fi

echo "┌─────────────────────────────────────────"
echo "|Updating repositories"
echo "└─────────────────────────────────────────"
apt-get update -yqq

# echo "┌─────────────────────────────────────────"
# echo "|Upgrading packages"
# echo "└─────────────────────────────────────────"
# apt-get upgrade -yqq

echo "┌─────────────────────────────────────────"
echo "|Installing and configuring nginx"
echo "└─────────────────────────────────────────"
apt-get install nginx -yqq

echo "┌─────────────────────────────────────────"
echo "|Setting up filesystem"
echo "└─────────────────────────────────────────"
mkdir -p /var/www/html/images
mkdir -p /var/www/html/passwords
mkdir -p /var/www/html/files
chmod 777 /var/www/html
chmod 777 /var/www/html/passwords
chmod 777 /var/www/html/images
chmod 777 /var/www/html/files
cp -u /home/pi/Captive-Portal/default_nginx /etc/nginx/sites-enabled/default
cp -u /home/pi/Captive-Portal/journald.conf /etc/systemd/journald.conf
cp -u /home/pi/Captive-Portal/index.php /var/www/html/index.php
cp -u /home/pi/Captive-Portal/index.html /var/www/html/index.html
cp -u /home/pi/Captive-Portal/data.txt /var/www/html/data.txt
cp -u /home/pi/Captive-Portal/download.php /var/www/html/download.php
cp -u /home/pi/Captive-Portal/submit.php /var/www/html/submit.php
cp -u /home/pi/Captive-Portal/Android.png /var/www/html/images/Android.png
cp -u /home/pi/Captive-Portal/spatiam.jpg /var/www/html/images/spatiam.jpg
cp -U /home/pi/Captive-Portal/submit.php /var/www/html/submit.php
cp -U /home/pi/Captive-Portal/DTN.apk /var/www/html/files/DTN.apk
cp -u /home/pi/Captive-Portal/watchpack.py /var/www/html/watchpack.py

echo "┌─────────────────────────────────────────"
echo "|Configuring Python"
echo "└─────────────────────────────────────────"
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2

echo "┌─────────────────────────────────────────"
echo "|Installing dnsmasq"
echo "└─────────────────────────────────────────"
apt-get install dnsmasq -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring wlan0"
echo "└─────────────────────────────────────────"
cp -u /home/pi/Captive-Portal/dhcpcd.conf /etc/dhcpcd.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring dnsmasq"
echo "└─────────────────────────────────────────"
cp -u /home/pi/Captive-Portal/dnsmasq.conf /etc/dnsmasq.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring dnsmasq to start at boot"
echo "└─────────────────────────────────────────"
update-rc.d dnsmasq defaults

echo "┌─────────────────────────────────────────"
echo "|Installing hostapd"
echo "└─────────────────────────────────────────"
apt-get install hostapd -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring hostapd"
echo "└─────────────────────────────────────────"
cp -u /home/pi/Captive-Portal/hostapd.conf /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

echo "┌─────────────────────────────────────────"
echo "|Setting country code"
echo "└─────────────────────────────────────────"
iw reg set US

echo "┌─────────────────────────────────────────"
echo "|Configuring iptables"
echo "└─────────────────────────────────────────"
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent

echo "┌─────────────────────────────────────────"
echo "|Configuring hostapd to start at boot"
echo "└─────────────────────────────────────────"
systemctl unmask hostapd.service
systemctl enable hostapd.service

echo "┌─────────────────────────────────────────"
echo "|Installing PHP7"
echo "└─────────────────────────────────────────"
apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-curl php7.3-gd php7.3-curl php7.3-zip php7.3-xml -yqq > /dev/null

echo "┌─────────────────────────────────────────"
echo "|Building watchpack service"
echo "└─────────────────────────────────────────"
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

echo "┌─────────────────────────────────────────"
echo "|Setting up GPS"
echo "└─────────────────────────────────────────"
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

echo "┌─────────────────────────────────────────"
echo "|Attempting reboot"
echo "└─────────────────────────────────────────"
reboot