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

if [ ! -f "${SSH_PUBKEY_PATH}" ]; then
  echo "Missing ${SSH_PUBKEY_PATH}. Please make sure keys."
  exit 1
fi

SSH_PUBKEY=`cat ${SSH_PUBKEY_PATH}`

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
