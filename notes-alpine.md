Base: Alpine for Raspberry Pi https://alpinelinux.org/downloads/

https://wiki.alpinelinux.org/wiki/Raspberry_Pi

```
cd AlpineLinux
curl -LO http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/armhf/alpine-rpi-3.7.0-armhf.tar.gz
git clone https://github.com/RPi-Distro/firmware-nonfree.git
git clone https://github.com/OpenELEC/misc-firmware.git
echo 'enable_uart=1' > usercfg.txt
cd ..
```

SDHC

```
sudo mkfs.vfat /dev/mmcblk0p1
```

mount

```
DISK=/media/stephane/????-????
# The sources are in ./AlpineLinux/
cd ./AlpineLinux/
tar xzvf alpine-rpi-3.6.2-armhf.tar.gz -C $DISK/
cp usercfg.txt $DISK/
BRCM=$DISK/firmware/brcm
mkdir -p $BRCM
cp firmware-nonfree/brcm80211/brcm/brcmfmac43430-sdio.* $BRCM/
cp misc-firmware/firmware/brcm/BCM43430A1.hcd $BRCM
sync
```

umount

Plug in raspi
Login as root (no password)
Plug network cable in
Plug keyboard

`setup-alpine -e ` (all defaults, except 1 for dl-cdn; this means chronyd and openssh)
`lbu commit`
`lbu commit -d`
`reboot`

```
adduser builder # with password, will use `su` to get root
# Note that /home/builder is not saved by lbu
passwd # set a password for root, so that builder can su
```

```
SSH_AUTH_SOCK= ssh -p 22 builder@192.168.4.77
su
lbu commit -d # etc…
```

`apk update`
`apk upgrade`

`apk add nodejs git gpsd`

Persistent storage
------------------

```
mount /media/mmcblk0p1 -o rw,remount
sed -i 's/vfat ro,/vfat rw,/' /etc/fstab
dd if=/dev/zero of=/media/mmcblk0p1/persist.img bs=1024 count=0 seek=1048576
apk add e2fsprogs
mkfs.ext4 /media/mmcblk0p1/persist.img
echo '/media/mmcblk0p1/persist.img /media/persist ext4 rw,relatime,errors=remount-ro 0 0' >> /etc/fstab
mkdir /media/persist
mount -a
mkdir /media/persist/usr
mkdir /media/persist/.work
echo 'overlay /usr overlay lowerdir=/usr,upperdir=/media/persist/usr,workdir=/media/persist/.work 0 0' >> /etc/fstab
mount -a
```

```
echo 'export NODE_PATH=/usr/lib/node_modules' >> /etc/profile
```

```
rc-update add swclock boot # enable the software clock
rc-update del hwclock boot # disable the hardware clock
lbu commit -d
reboot
```

The content of the FAT32 is at /media/mmcblk0p1

https://wiki.alpinelinux.org/wiki/Raspberry_Pi_3_-_Setting_Up_Bluetooth
https://wiki.alpinelinux.org/wiki/Raspberry_Pi_3_-_Configuring_it_as_wireless_access_point_-AP_Mode

Master
------

```
apk add hostapd dnsmasq
cat > /etc/hostapd/hostapd.conf <<'EOF'
interface=wlan0
driver=nl80211
ssid=Pi3-AP
hw_mode=g
channel=1
macaddr_acl=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=raspberry
rsn_pairwise=CCMP
wpa_pairwise=CCMP
EOF
cat > /etc/dnsmasq.conf <<'EOF'
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
EOF
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
  hostname rpi-master
auto wlan0
iface wlan0 inet static
  address 10.0.0.1
  netmask 255.255.255.0
EOF

service dnsmasq start
service hostapd start

rc-update add dnsmasq
rc-update add hostapd

lbu ci -d
reboot

```

Client
------

https://wiki.debian.org/WiFi/HowToUse#WPA-PSK_and_WPA2-PSK

```
apk add wpa_supplicant
wpa_passphrase Pi3-AP raspberry > /etc/wpa_supplicant/wpa_supplicant.conf
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
  hostname rpi-client
auto wlan0
iface wlan0 inet dhcp
  wpa-ssid Pi3-AP
EOF

service wpa_supplicant start
rc-update add wpa_supplicant
```

Note: wpa-supplicant starts late, so the WLAN interface will not have its IP address ready right away.

GPSD
----

`apk add gpsd`

This is some initial configuration to make sure that GPSD receives the messages from the USB port:

```
cat > /etc/conf.d/gpsd <<'EOF'
DEVICE="/dev/ttyUSB0"
BAUDRATE="115200"
ARGS="-n "
/bin/stty -F ${DEVICE} ${BAUDRATE}
# /bin/setserial ${DEVICE} low_latency
EOF

service gpsd start

rc-update add gpsd
lbu ci -d
```

nc localhost 2947
?WATCH={"enable":true,"json":true};


However the final configuration (using `brave-chin`) will require GPSD to use

```
cat > /etc/conf.d/gpsd <<'EOF'
# GPSD will connect to brave-chin on port 5050
DEVICE="udp://127.0.0.1:5050"
ARGS="-n "
EOF
```


Raspi tools
-----------

apk add raspberrypi # https://pkgs.alpinelinux.org/contents?branch=v3.6&name=raspberrypi&arch=armhf&repo=main

/opt/vc/bin/tvservice -o # power off HDMI

# Turn off the LED
echo gpio > /sys/class/leds/led1/trigger
echo 0 > /sys/class/leds/led1/brightness

GPIO
----

`npm install wiring-pi` (to be tested)
