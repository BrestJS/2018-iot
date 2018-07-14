The Raspberry Pi3 is now (Alpine Linux 3.8) supported natively in 64 bits mode.

Download and install the Raspberry Pi `aarch64` image from https://alpinelinux.org/downloads/

Additionally, the manual changes I referenced for 3.7 (adding `usercfg.txt`, downloading firmwares, see [notes-alpine.md](notes-alpine.md)) are included in 3.8; in other words, the system can be booted directly by copying the files in the 3.8 image to a micro-SD card.

The newer `setup-alpine` script will also autodetect WLAN SSIDs and help you set network up.

However you still need to do (based on the [Pi documentation](https://wiki.alpinelinux.org/wiki/Raspberry_Pi)
```
rc-update add swclock boot    # enable the software clock
rc-update del hwclock boot    # disable the hardware clock
```
to simplify the boot.

Using SSH without a persistent image
------------------------------------

I put the `authorized_keys` in `/etc/root/root_authorized_keys` and added
```
Match User root
  AuthorizedKeysFile /etc/ssh/root_authorized_keys
```
at the end of `/etc/sshd/sshd_config`.

Since the file is included in the `lbu commit`, and root always has a home directory, this allows remote login without the need for a persistent image.

Using as routing AP
-------------------

To use as a routing AP (no NAT, supports both IPv4 and IPv6), I had to add in sysctl:
```
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.wlan0.accept_ra = 0
net.ipv6.conf.wlan0.accept_dad = 0
net.ipv6.conf.wlan0.autoconf = 0
```

while `/etc/dnsmasq.conf` contains:
```
# List the interfaces we are ready to manage.
interface=eth0
interface=wlan0
# Enable Router Advertisement
enable-ra
# On eth0, advertise prefixes but not a route via ourselves
ra-param=eth0,0,0
# LAN/eth0 - IPv4
dhcp-range=set:lan4,192.168.1.100,192.168.1.200,255.255.255.0,12h
dhcp-option=tag:lan4,option:router,192.168.1.1
# LAN/eth0 - IPv6
dhcp-range=set:lan6,::1,constructor:eth0,ra-only
# WLAN/wlan0 - IPv4
dhcp-range=set:wlan4,192.168.5.100,192.168.5.199,255.255.255.0,12h
dhcp-option=tag:wlan4,option:router,192.168.5.1
# WLAN/wlan0 - IPv6
dhcp-range=set:wlan6,::5,constructor:wlan0
```

and finally `/etc/network/interfaces`:
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 192.168.1.2
  netmask 255.255.255.0
  gateway 192.168.1.1
iface eth0 inet6 static
  address 2001:xxxx:yyyy:1::2 # replace xxxx:yyyy
  netmask 64

auto wlan0
iface wlan0 inet static
  address 192.168.5.1
  netmask 255.255.255.0
iface wlan0 inet6 static
  address 2001:xxxx:yyyy:5::1 # replace xxxx:yyyy
  netmask 64
```

On my default gateway (192.168.1.1) I added two static routes (one IPv4, one IPv6) pointing to 192.168.1.2 (for a route to 192.168.5.0/24) and to 2001:xxxx:yyyy:1::2 (for a route to 2001:xxxx:yyyy:5::/64).
