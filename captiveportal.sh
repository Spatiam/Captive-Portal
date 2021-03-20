#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo -e "\e[39m\e[31mMust be root, run sudo -i before running this script.\e[39m"
	exit
fi

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mUpdating repositories\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get update -yqq
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mInstalling and configuring nginx\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get install nginx -yqq
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mSetting up filesystem\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
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
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring Python\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mInstalling dnsmasq\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get install dnsmasq -yqq
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring wlan0\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
cp -u /home/pi/Captive-Portal/config_files/dhcpcd.conf /etc/dhcpcd.conf
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring dnsmasq\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
cp -u /home/pi/Captive-Portal/config_files/dnsmasq.conf /etc/dnsmasq.conf
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring dnsmasq to start at boot\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
update-rc.d dnsmasq defaults
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mInstalling hostapd\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get install hostapd -yqq
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring hostapd\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
cp -u /home/pi/Captive-Portal/config_files/hostapd.conf /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mSetting country code\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
iw reg set US
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring iptables\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo -e iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo -e iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mConfiguring hostapd to start at boot\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
systemctl unmask hostapd.service
systemctl enable hostapd.service
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mInstalling PHP7\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-curl php7.3-gd php7.3-curl php7.3-zip php7.3-xml -yqq > /dev/null
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mBuilding watchpack service\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
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
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mSetting up GPS\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
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
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mBuilding Ion\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
tar -xvzf /home/pi/ion-open-source-4.0.2.tar.gz -C /home/pi
(cd /home/pi/ion-open-source-4.0.2 && ./configure)
(cd /home/pi/ion-open-source-4.0.2 && make)
(cd /home/pi/ion-open-source-4.0.2 && sudo make install)
sudo ldconfig
rm -r -f /home/pi/ion-open-source-4.0.2.tar.gz
mkdir /home/pi/ion-open-source-4.0.2/dtn
mv -u /home/pi/Captive-Portal/config_files/mule.rc /home/pi/ion-open-source-4.0.2/dtn/mule.rc
mv -u /home/pi/Captive-Portal/ion/incoming.txt /home/pi/ion-open-source-4.0.2/dtn/incoming.txt
killm
ionstart -I /home/pi/ion-open-source-4.0.2/dtn/mule.rc
ss -panu
ipcs
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mBuilding pyion\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
sudo mv -u /home/pi/Captive-Portal/pyion /home/pi/pyion
export ION_HOME=/home/pi/ion-open-source-4.0.2
(cd /home/pi/pyion && sudo -E python setup.py install)
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[39mReoot required\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
read -n 1 -s -r -p "Press any key to reboot"
reboot