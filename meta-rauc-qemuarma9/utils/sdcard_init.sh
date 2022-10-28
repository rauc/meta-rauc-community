#!/bin/sh

file="sd.img"
if [ -f "$file" ] ; then
    read -p "An sd.img file already exists. Are you sure you want to delete it and create a new one? (y/n) " input
    if [ "$input" != "y" ]; then
        exit
    fi
    
    echo "Removing old sd.img"
    rm "$file"
fi

echo "Creating empty sd.img file"
dd if=/dev/zero of=sd.img bs=1M count=1000
echo "Copying content from wic file"
dd if=core-image-minimal-qemuarma9.wic of=sd.img conv=notrunc
echo "Resize rootfs partition to take the whole sd.img size"
parted -s sd.img resizepart 2 100%

