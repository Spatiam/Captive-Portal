#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo -e "\e[39m\e[31mMust be root, run sudo -i before running this script.\e[39m"
	exit
fi

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mUpdating repositories\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
apt-get update -yqq
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mSetting up filesystem\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
mv -u /home/pi/Captive-Portal/ion/ion-open-source-4.0.2.tar.gz /home/pi/ion-open-source-4.0.2.tar.gz
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mConfiguring Python\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mSetting country code\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
iw reg set US
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mBuilding Ion\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
tar -xvzf /home/pi/ion-open-source-4.0.2.tar.gz -C /home/pi
(cd /home/pi/ion-open-source-4.0.2 && ./configure)
(cd /home/pi/ion-open-source-4.0.2 && make)
(cd /home/pi/ion-open-source-4.0.2 && sudo make install)
sudo ldconfig
rm -r -f /home/pi/ion-open-source-4.0.2.tar.gz
mkdir /home/pi/ion-open-source-4.0.2/dtn
mv -u /home/pi/Captive-Portal/config_files/client.rc /home/pi/ion-open-source-4.0.2/dtn/client.rc
killm
ionstart -I /home/pi/ion-open-source-4.0.2/dtn/client.rc
ss -panu
ipcs
echo -e "\e[32mDONE"

echo -e "\e[33m┌─────────────────────────────────────────"
echo -e "|\e[0;30;47mReoot required\e[39m\e[33m"
echo -e "└─────────────────────────────────────────\e[39m"
read -n 1 -s -r -p "\e[36mPress any key to reboot\e[39m"
reboot