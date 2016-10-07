#!/bin/bash

        
#########
#### DEBIAN
#########

SELF_DESKTOP=chdroid_desktop.sh

IMGDIR=/sdcard/chdroid/sources
IMGNAME=debian.source

INSTALLDEBOOTSTRAP="pacman -y debootstrap"  #"apt-get install debootstrap"

ARCH=amd64
DISTRIB=jessie
BUILDIMGDIR=/tmp
INITIMGSIZE=300

function debian_genimage {
	echo "Installing debootsrap"
	$INSTALLDEBOOTSTRAP
	echo "Generating Image"
	cd $BUILDIMGDIR	
	dd if=/dev/zero of=debian.img bs=1M count=$INITIMGSIZE
	mkfs.ext4 $IMGNAME
		if [ ! -d debian ]; then
		  mkdir -p debian
	fi
	mount -o loop  $IMGNAME debian/
	debootstrap --verbose --arch $ARCH --foreign $DISTRIB debian http://ftp.debian.org/debian
	umount debian/
	rm -r debian/
 	e2fsck -f $IMGNAME
  resize2fs -M $IMGNAME
	adb push -p  $IMGNAME $IMGDIR/

}
 
   
#########
#### 
#########


#######
### Main
#######

if [ $EUID -ne 0 ]
then
	echo "Becoming ROOT!"
	su -c $SELF_DESKTOP
	exit 1
fi

OPTIONS="MakeImage  Exit"

select opt in $OPTIONS; do
   if [ "$opt" = "MakeImage" ]; then
    debian_genimage
   elif [ "$opt" = "Update" ]; then
    adb shell -c pitch_update
   elif [ "$opt" = "Exit" ]; then
    echo done
    exit
   else
    clear
    echo bad option
   fi
done

exit 0