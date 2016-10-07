 #!/bin/bash



function remountsys {
	mount -o remount,rw /system
}

function mount_partsd {
  $busybox mount -t ext4 -o noatime,nodiratime,errors=panic $SDCARDDEV $MNTDIR 
}


function view_part {
	mount ; ls -l /dev/block
}