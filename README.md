```
sudo -i
```

```
sudo bash /home/pi/Captive-Portal/captiveportal.sh $0
```

```
sudo raspi-config
5
L4
US
sudo systemctl restart hostapd.service
sudo reboot
```



Below sites needs to be resolvable to public IPs for CP to work
connectivitycheck.gstatic.com
www.gstatic.com
www.apple.com
captive.apple.com
clients3.google.com

Those IPs needs to be NATed to the pi so basically NAT everything from WiFi to the RPI

#### Troubleshooting

Install and capture traffic using `tcpdump -i wlan0 -w filename.pcap`

Check nginx logs

#### Other

```


# Go to /var/logs/
cd /var/logs/

# Find all gz files and extract them
find . -name '*.gz' -execdir gunzip '{}' \;

# Find MAC addresses in all files and dont show duplicates and other stuff
grep -hoiIs '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' * | sort -u


NGINX logs
# Go to /var/logs/
cd /var/logs/nginx/

# Find all unique IP addresses that connected to the website. This will show 192...
grep -hoiIs -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' * | sort -u

# Find all unique IP addresses that connected to the website. This will show more details, like what (kind of) device connected.
grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' * | sort -u```

```