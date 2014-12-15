#Yosemite Login and logout hooks are now work

RAMDisk() {
  mntpt=$1
  rdsize=$(($2*1024*1024/512))
  mntname=$3
  # Create the RAM disk.
  dev=`hdid -nomount ram://$rdsize`
  # Successfull creation...
  if [ $? -eq 0 ] ; then
    # Create HFS on the RAM volume.
    newfs_hfs -v ${mntname} ${dev}
    # Store permissions from old mount point.
    eval `/usr/bin/stat -s $mntpt`
    #make dir
    mkdir -p ${mntpt}
    #mount ramdisk to target mount point
    mount -o noatime -o union -o nobrowse -o nodev -t hfs ${dev} ${mntpt}
    # Restore permissions like they were on old volume.
    chown $st_uid:$st_gid $mntpt
    chmod $st_mode $mntpt
  else
    touch /Users/khacpm/Desktop/${mntname}.txt
  fi
}

RAMDisk /private/tmp 256 TMP
RAMDisk /var/run 700 RNUN
RAMDisk /Library/Caches 64 SYSCACHES
RAMDisk ~/Library/Developer/Xcode/DerivedData 2048 DerivedData
RAMDisk ~/Library/Caches 1024 USERCACHES
RAMDisk "~/Library/Application\ Support/iPhone\ Simulator" 384 Simulator
