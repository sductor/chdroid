#!/system/bin/sh

#########
#### CONFIG
#########

CHDROIDFOLDER=/sdcard/chdroid
#DISTRIB=funtoo
#DISTRIB=arch
DISTRIB=debian

ROOTFSDIR=$CHDROIDFOLDER/rootfs/$DISTRIB
IMGDIR=$CHDROIDFOLDER/images
IMG=$IMGDIR/$DISTRIB.img
SOURCEDIR=$CHDROIDFOLDER/sources
SOURCE=$SOURCEDIR/$DISTRIB.source
SCRIPTDIR=$CHDROIDFOLDER/scripts

POSTINSTALLSCRIPT=chdroid-pi_$DISTRIB.sh
STARTSCRIPT=chdroid-start_$DISTRIB.sh
STARTXSCRIPT=chdroid-startx_$DISTRIB.sh
#FUNTOOSOURCE=???
#ARCHSOURCE=???

IMGSIZE=10G

busybox=/system/xbin/busybox

LOOPNO=254
LOOPDEV=/dev/block/loop$LOOPNO

SDCARD0DIR=$(readlink -f /sdcard)
SDCARD1DIR=/storage/sdcard1 
SDCARD0MNTDIR=media/android
SDCARD1MNTDIR=media/ext

<<<<<<< HEAD
########
#### Updating
########

function update_scripts {
	mount -o remount,rw /system
	cp $SCRIPTDIR/chdroid.sh	 /system/xbin/chdroid
  chmod 777  /system/xbin/chdroid
	cp $SCRIPTDIR/chdroid-util.sh	 /system/xbin/chdroid-util
  chmod 777  /system/xbin/chdroid-util 
	cp $SCRIPTDIR/chdroid-conf.sh	 /system/xbin/chdroid-conf
  chmod 777  /system/xbin/chdroid-conf
	if [ ! -d /system/su.d ]; then
       mkdir -m700 /system/su.d
  fi
  cp $SCRIPTDIR/chdroid-automount.sh	 /system/su.d
  chmod 777  /system/su.d/chdroid-automount.sh
  mount -r -o remount /system
}



#######
### Main
#######

while [[ $# -gt 1 ]]
do
opt="$1"
	case $opt in
		  -t|--root-folder)
			CHDROIDFOLDER="$2"
		  echo "Root folder is ..." $CHDROIDFOLDER
		  shift # past argument
		  ;;
		  -d|--distrib)
		  DISTRIB="$2"
		  echo "Distrib is ..." $DISTRIB
		  shift # past argument
		  shift # past argument or value
		  ;;
		  -s|--size)
		  IMGSIZE="$2"
		  echo "Image size is ..." $IMGSIZE
		  shift # past argument
		  shift # past argument or value
		  ;;
		  *) ;;
	esac
done

