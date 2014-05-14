#!/bin/bash
cd /Library/LaunchDaemons
sudo rm -rf com.magik.ramfs.plist
cat << EOF | sudo tee com.magik.ramfs.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.magik.ramfs</string>
<key>ProgramArguments</key>
<array>
<string>/var/root/ramfs.sh</string>
</array>
<key>RunAtLoad</key>
<true/>
</dict>
</plist>
EOF

cd /var/root
sudo rm -rf ramfs.sh
cat << EOF | sudo tee ramfs.sh > /dev/null
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
RAMDisk /var/run 64 RNUN
RAMDisk /Library/Caches 64 SYSCACHES
RAMDisk /Users/khacpm/Library/Developer/Xcode/DerivedData 2048 DerivedData
RAMDisk /Users/khacpm/Library/Caches 1024 USERCACHES
RAMDisk /Users/khacpm/Library/Application Support/iPhone Simulator 384 Simulator
EOF

chmod +x /var/root/ramfs.sh
