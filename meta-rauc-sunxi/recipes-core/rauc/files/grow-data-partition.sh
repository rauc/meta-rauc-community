#!/bin/sh

total_disk_size=$(cat /sys/block/mmcblk0/size)

data_part_size=$(cat /sys/block/mmcblk0/mmcblk0p4/size)
data_part_start=$(cat /sys/block/mmcblk0/mmcblk0p4/start)

if [ -z "${total_disk_size}" ] || [ -z "${data_part_size}" ] || [ -z "${data_part_start}" ]; then
    echo "Failed to read disk sizes. Aborting..."
    exit 1
fi

data_part_end=$(expr ${data_part_start} + ${data_part_size})

# expr returns 1 (error) if the result is 0, which terminates the script
# because of 'set -e'. Silence this error
free_space=$(expr ${total_disk_size} - ${data_part_end} || true)

# If there is less than 8196 blocks = 4 MiB free unused space, we consider
# the disk as already resized. After resizing, some disk space may still
# have been left unused.
if [ ${free_space} -lt 8196 ]; then
    echo "Disk has already been resized."
    exit 0
fi

/usr/bin/umount /dev/mmcblk0p4
/usr/sbin/sgdisk /dev/mmcblk0 -e
/usr/sbin/partprobe
/usr/sbin/parted --script /dev/mmcblk0 resizepart 4 100%
/usr/sbin/resize2fs /dev/mmcblk0p4
/usr/bin/umount /dev/mmcblk0p4
/usr/sbin/e2fsck -fp /dev/mmcblk0p4
/usr/bin/mount /dev/mmcblk0p4 /data/

echo "Disk resized."
exit 0
