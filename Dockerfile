FROM ubuntu:12.04
MAINTAINER YungSang "yungsang@gmail.com"

ENV SYSLINUX_VERSION 6.02
ENV COREOS_ARCH      amd64-usr
ENV COREOS_VERSION   alpha

ENV BOOT_ENV         bios
ENV CURL             curl
ENV SSH_PUBKEY_PATH  oem/authorized_keys

# Initialze variables
ENV SYSLINUX_BASE_URL      ftp://www.kernel.org/pub/linux/utils/boot/syslinux
ENV SYSLINUX_BASENAME      syslinux-$SYSLINUX_VERSION
ENV SYSLINUX_URL           $SYSLINUX_BASE_URL/$SYSLINUX_BASENAME.tar.gz

ENV COREOS_BASE_URL        http://storage.core-os.net/coreos
ENV COREOS_KERN_BASENAME   coreos_production_pxe.vmlinuz
ENV COREOS_INITRD_BASENAME coreos_production_pxe_image.cpio.gz
ENV COREOS_VER_URL         $COREOS_BASE_URL/$COREOS_ARCH/$COREOS_VERSION/version.txt
ENV COREOS_KERN_URL        $COREOS_BASE_URL/$COREOS_ARCH/$COREOS_VERSION/$COREOS_KERN_BASENAME
ENV COREOS_INITRD_URL      $COREOS_BASE_URL/$COREOS_ARCH/$COREOS_VERSION/$COREOS_INITRD_BASENAME

WORKDIR /coreos

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get -y install curl mkisofs syslinux

RUN mkdir -p iso/coreos && \
    mkdir -p iso/syslinux && \
    mkdir -p iso/isolinux

RUN echo "-----> CoreOS version" && \
    $CURL -o version.txt $COREOS_VER_URL && \
    cat version.txt

RUN echo "-----> Download CoreOS's kernel" && \
    if [ ! -e iso/coreos/vmlinuz ]; then \
      $CURL -o iso/coreos/vmlinuz $COREOS_KERN_URL; \
    fi

RUN echo "-----> Download CoreOS's initrd" && \
    if [ ! -e iso/coreos/cpio.gz ]; then \
      $CURL -o iso/coreos/cpio.gz $COREOS_INITRD_URL; \
    fi

RUN echo "-----> Download syslinux and copy to iso directory" && \
    if [ ! -e $SYSLINUX_BASENAME ]; then \
      $CURL -o $SYSLINUX_BASENAME.tar.gz $SYSLINUX_URL; \
    fi && \
    tar zxf $SYSLINUX_BASENAME.tar.gz && \
    chown -R root:root $SYSLINUX_BASENAME && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/com32/chain/chain.c32 iso/syslinux/ && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/com32/lib/libcom32.c32 iso/syslinux/ && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/com32/libutil/libutil.c32 iso/syslinux/ && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/memdisk/memdisk iso/syslinux/ && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/core/isolinux.bin iso/isolinux/ && \
    cp $SYSLINUX_BASENAME/$BOOT_ENV/com32/elflink/ldlinux/ldlinux.c32 iso/isolinux/

ADD oem/ /coreos/oem/

RUN chown -R root:root oem/

ADD makeiso.sh /coreos/

RUN chown root:root makeiso.sh

CMD ["/bin/sh", "makeiso.sh"]
