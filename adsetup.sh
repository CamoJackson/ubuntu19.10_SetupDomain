#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please! run as root"
  exit
fi

set -e

# get latest adcli
wget http://http.us.debian.org/debian/pool/main/a/adcli/adcli_0.9.0-1_amd64.deb
# install latest adcli
dpkg -i adcli_0.9.0-1_amd64.deb
rm adcli_0.9.0-1_amd64.deb
# install domain tools
apt update
apt -y install realmd sssd sssd-tools libnss-sss libpam-sss samba-common-bin oddjob oddjob-mkhomedir packagekit libsasl2-modules-gssapi-mit

echo Enter Domain name
read dname
echo Enter Username
read uname
echo Enter Password
read passwd

realm discover $dname
realm join $dname --user=$uname --one-time-password=$passwd

# Add dynamic DNS to SSSD
sudo echo 'dyndns_update = true \
dyndns_refresh_interval = 43200 \
dyndns_update_ptr = true \
dyndns_ttl = 360' >> /etc/sssd/sssd.conf

# Add Domain Admins To Sudoers
echo %domain\ admins@$dname ALL=(ALL) ALL >> /etc/sudoers
