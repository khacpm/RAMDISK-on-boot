#!/bin/bash
trap 'echo "error at line $LINENO" >> /Users/khacpm/loginerror.txt' ERR
function shutdown()
{
	hdiutil detach /private/tmp -force
	hdiutil detach /var/run -force
	hdiutil detach /Users/khacpm/Library/Caches -force
	hdiutil detach /Users/khacpm/Library/Developer/Xcode/DerivedData -force
	#hdiutil detach /Users/khacpm/TMP -force
	exit 0
}

function startup()
{
	RAMDisk /Users/khacpm/Library/Caches 770 UCACHES
	RAMDisk /private/tmp 256 TMP
	RAMDisk /var/run 64 VARUN
	RAMDisk /Users/khacpm/Library/Developer/Xcode/DerivedData 3072 DerivedData
}

function RAMDisk()
{
	mntpt=$1
	rdsize=$(($2*1024*1024/512))
	mntname=$3
# Create the RAM disk.
	dev=`hdid -nomount ram://$rdsize`
# Successfull creation...
	if [ $? -eq 0 ] ; then
# Create HFS on the RAM volume.
		newfs_hfs -v ${mntname} ${dev}
# Make dir
		mkdir -p ${mntpt}
# Store permissions from old mount point.
		eval `/usr/bin/stat -s ${mntpt}`
#mount ramdisk to target mount point
		mount -o noatime,union,nobrowse -t hfs ${dev} ${mntpt}
# Restore permissions like they were on old volume.
		chown $st_uid:$st_gid ${mntpt}
		chmod $st_mode ${mntpt}
	else
		touch /Users/khacpm/Desktop/${mntname}.txt
	fi
}

trap shutdown SIGTERM
#trap shutdown SIGKILL

startup;
