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

LOGINCMD=bash -l




########
#### Primitives
########

function update_scripts {
	mount -o remount,rw /system
	cp $SCRIPTDIR/chdroid.sh	 /system/xbin/chdroid && chmod 777  /system/xbin/chdroid
	cp $SCRIPTDIR/chdroid-util.sh	 /system/xbin/chdroid-util && chmod 777  /system/xbin/chdroid-util 
	if [ ! -d /system/su.d ]; then
       mkdir -m700 /system/su.d
     fi
    cp $SCRIPTDIR/chdroid-droidinit.sh	 /system/su.d && chmod 777  /system/su.d/chdroid-droidinit.sh
    mount -r -o remount /system
}

function mnt {
  mknod $LOOPDEV b 7 $LOOPNO
	losetup $LOOPDEV $IMG
	$busybox mount -t ext4 -o relatime $LOOPDEV $ROOTFSDIR
	for f in dev dev/pts proc sys ; do $busybox mount -o bind /$f $ROOTFSDIR/$f ; done
	if [ ! -d $ROOTFSDIR/$SDCARD0MNTDIR ]; then
			mount -o remount,rw /system
		  mkdir -p $ROOTFSDIR/$SDCARD0MNTDIR
	fi
	if [ ! -d $ROOTFSDIR/$SDCARD1MNTDIR ]; then
			mount -o remount,rw /system
		  mkdir -p $ROOTFSDIR/$SDCARD1MNTDIR
	fi
	$busybox mount -o bind $SDCARD0DIR $ROOTFSDIR/$SDCARD0MNTDIR
	$busybox mount -o bind $SDCARD1DIR $ROOTFSDIR/$SDCARD1MNTDIR
}

function log_in {
	env -i  USER=root HOME=/root TERM=$TERM PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $busybox chroot $ROOTFSDIR $LOGINCMD
}
function startx {
	env -i  USER=root HOME=/root TERM=$TERM PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $busybox chroot $ROOTFSDIR  bash -l -c $STARTXSCRIPT
}


function unmnt {
	for f in dev/pts dev proc sys ; do umount $ROOTFSDIR/$f ; done
	umount $ROOTFSDIR
	losetup -d $LOOPDEV
	rm $LOOPDEV
}

function mkimg_tar {
		#wget -c $REMOTESOURCE
	  cp $EMPTYIMG $IMG
		resize2fs $IMG $IMGSIZE
		$busybox mount -o loop $IMG $CHDROIDFOLDER/temp_img/
		tar xz -f $SOURCE -C $CHDROIDFOLDER/temp_img/
		umount $CHDROIDFOLDER/temp_img/
		rm -r $CHDROIDFOLDER/temp_img/
}

 
function install {
	#if arch funtoo then mkimg_tar
	echo "copying the source image as new rootfs img"
	cp $SOURCE $IMG
	resize2fs $IMG $IMGSIZE
	echo "Mounting"
	mnt
  echo "copying post install script"
	cp $SCRIPTDIR/$POSTINSTALLSCRIPT $ROOTFSDIR/usr/bin/
	chmod 777 $ROOTFSDIR/usr/bin/$POSTINSTALLSCRIPT
	cp $SCRIPTDIR/vncserver $ROOTFSDIR/etc/init.d/
	chmod 777 $ROOTFSDIR/etc/init.d/vncservery
	cp $SCRIPTDIR/resolv.conf-default $ROOTFSDIR/etc/
	cp $SCRIPTDIR/$STARTSCRIPT $ROOTFSDIR/etc/chdroid-start
	echo "source /etc/chdroid-start" >> $ROOTFSDIR/etc/profile
	echo "Logging in"
	env -i  USER=root HOME=/root TERM=$TERM PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $busybox chroot $ROOTFSDIR bash -l -c $POSTINSTALLSCRIPT
}
 
#######
### Main
#######

echo "This is chroot for Android"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -t|--root-folder)
		CHDROIDFOLDER="$2"
    shift # past argument
    ;;
    -d|--distrib)
    DISTRIB="$2"
    shift # past argument
    shift # past argument or value
    ;;
    -s|--size)
    IMGSIZE="$2"
    shift # past argument
    shift # past argument or value
    ;;
    mount)
    echo "mounting..."
    mnt
		break
    ;;
    login)
    log_in
    exit
    ;;
    startx)
    startx
    exit
    ;;
    *)
    # unknown option
    ;;
esac
done



OPTIONS="Mount Login Umount Install Update Exit"

select opt in $OPTIONS; do
   if [ "$opt" = "Mount" ]; then
    mnt
   elif [ "$opt" = "Login" ]; then
    log_in
		exit
   elif [ "$opt" = "Install" ]; then
    install
		exit
   elif [ "$opt" = "Umount" ]; then
    umnt
   elif [ "$opt" = "Update" ]; then
    update_scripts 
   elif [ "$opt" = "Exit" ]; then
    echo Exiting
    exit
   else
    clear
    echo bad option
   fi
done

exit 0
