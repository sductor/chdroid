#!/system/xbin/bash
export PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin

log=$CHDROIDFOLDER/chdroid.log
[[ $(du -m "$log" | awk '{print $1}') -gt 20 ]] && mv "$log"{,.old}
exec >>"$log" 2>&1
echo " --- Started $(TZ=UTC date) --- "

log -p i -t chdroid "Mounting..."
chdroid mount &
disown

log -p i -t chroots "Finished chroots init"

echo " --- Finished $(TZ=UTC date) --- "