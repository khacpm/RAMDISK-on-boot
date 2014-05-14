#RAMDISK
#!/bin/bash
cd /System/Library/StartupItems
sudo rm -r -f RamFS
sudo mkdir RamFS
sudo chown -R root:wheel RamFS
sudo chmod -R u+rwX,g+rX,o+rX RamFS
cat << "EOF" | sudo tee RamFS/RamFS > /dev/null
#!/bin/sh
# Create a RAM disk with same perms as mountpoint


RAMDisk() {
mntpt=$1
rdsize=$(($2*1024*1024/512))
echo "Creating RamFS for $mntpt $rdsize"
# Create the RAM disk.
dev=`hdik -drivekey system-image=yes -nomount ram://$rdsize`
# Successfull creation...
if [ $? -eq 0 ] ; then
# Create HFS on the RAM volume.
newfs_hfs $dev
# Store permissions from old mount point.
eval `/usr/bin/stat -s $mntpt`
# Mount the RAM disk to the target mount point.
mount -t hfs -o union -o nobrowse -o noatime -o nodev $dev $mntpt
# Restore permissions like they were on old volume.
chown $st_uid:$st_gid $mntpt
chmod $st_mode $mntpt
fi
}

StartService () {
ConsoleMessage "Starting RamFS disks..."

RAMDisk /private/tmp 256
RAMDisk /var/run 64
RAMDisk /Library/Caches 64

RAMDisk /Users/khacpm/Library/Developer/Xcode/DerivedData 2048
RAMDisk /Users/khacpm/Library/Caches 1024
RAMDisk /Users/khacpm/Library/Application Support/iPhone Simulator 384
}
StopService () {
ConsoleMessage "Stopping RamFS disks, nothing will be done here..."
}

RestartService () {
ConsoleMessage "Restarting RamFS disks, nothing will be done here..."
}

RunService "$1"
EOF
sudo chmod u+x,g+x,o+x RamFS/RamFS



cat << EOF | sudo tee RamFS/StartupParameters.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist SYSTEM "file://localhost/System/Library/DTDs/PropertyList.dtd">
<plist version="0.9">
<dict>
<key>Description</key>
<string>RamFS Disks Manager</string>
<key>OrderPreference</key>
<string>Early</string>
<key>Provides</key>
<array>
<string>RamFS</string>
</array>
<key>Uses</key>
<array>
<string>Disks</string>
</array>
</dict>
</plist>
EOF

