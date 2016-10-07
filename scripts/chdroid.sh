#!/system/bin/sh

                
source /system/xbin/chdroid-conf







########
#### Updating
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


#######
### Mounting
#######

function mnt {
  mknod $LOOPDEV b 7 $LOOPNO
	losetup $LOOPDEV $IMG
	$busybox mount -t ext4 -o relatime $LOOPDEV $ROOTFSDIR
	for f in dev dev/pts proc sys ; do $busybox mount -o bind /$f $ROOTFSDIR/$f ; done
	$busybox mount -o bind $SDCARD0DIR $ROOTFSDIR/$SDCARD0MNTDIR
	$busybox mount -o bind $SDCARD1DIR $ROOTFSDIR/$SDCARD1MNTDIR
}


function unmnt {
	for f in dev/pts dev proc sys ; do umount $ROOTFSDIR/$f ; done
	umount $ROOTFSDIR
	losetup -d $LOOPDEV
	rm $LOOPDEV
}



#######
### Starting
#######



function log_in {
	env -i  USER=root HOME=/root TERM=$TERM PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $busybox chroot $ROOTFSDIR bash -l 
}
function startx {
	env -i  USER=root HOME=/root TERM=$TERM PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $busybox chroot $ROOTFSDIR  bash -l -c $STARTXSCRIPT
}


#######
### Installation
#######

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
  echo "creating env directories"
	mount -o remount,rw /system
  mkdir -p $ROOTFSDIR/$SDCARD0MNTDIR
  mkdir -p $ROOTFSDIR/$SDCARD1MNTDIR
  mount -r -o remount /system
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
### SubMain
#######

function interactive_menu {
  OPTIONS="Mount Login Startx Umount Install Update Exit"
	select opt in $OPTIONS; do
		 if [ "$opt" = "Mount" ]; then
			mnt
		 elif [ "$opt" = "Login" ]; then
			log_in
			exit
		 elif [ "$opt" = "Startx" ]; then
			startx
			exit
		 elif [ "$opt" = "Install" ]; then
			install
			exit
		 elif [ "$opt" = "Umount" ]; then
			umnt
		 elif [ "$opt" = "Update" ]; then
			update_scripts 
			exit
		 elif [ "$opt" = "Exit" ]; then
			echo Exiting
			exit
		 else
			clear
			echo bad option
		 fi
	done
}

function usage {

}

#######
### Main
#######

echo "This is chroot for Android"

cmd="$1"
case $cmd in
  i|interactive) interactive_menu                          ;;
  m|mount)     echo "mounting..."   	    ; mnt		       	 ;;
  u|umount)    echo "unmounting..." 	    ; umnt 	      	 ;;
  l|login)     echo "login..."      	    ; log_in       	 ;;
  x|startx)    echo "starting x..."       ; startx         ;;
  in|install)  echo "installing..."       ; install        ;;
  up|update)   echo "updating scripts..." ; update_scripts ;;
  *)           echo "unknown option"      ; usage          ;;
esac




exit 0
