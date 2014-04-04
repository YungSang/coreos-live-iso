#!/bin/sh
# Author: Naoki OKAMURA (Nyarla) <nyarla[ at ]thotep.net>
# Usage: ./makeiso.sh
# Unlicense: This script is under the public domain.
# Requires: gzip tar mkisofs syslinux curl (or axel) ssh

set -e
 
echo "-----> Make isolinux.cfg file"
cat<<EOF > iso/isolinux/isolinux.cfg
INCLUDE /syslinux/syslinux.cfg
EOF

SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

echo "-----> Make syslinux.cfg file"
cat<<EOF > iso/syslinux/syslinux.cfg
default coreos
prompt 1
timeout 15
 
label coreos
  kernel /coreos/vmlinuz
  append initrd=/coreos/cpio.gz root=squashfs: state=tmpfs: sshkey="${SSH_PUBKEY}"
EOF
 
echo "-----> Make ISO file"
cd iso
mkisofs -v -l -r -J -o /coreos.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table .
isohybrid /coreos.iso

echo "-----> Finished"
