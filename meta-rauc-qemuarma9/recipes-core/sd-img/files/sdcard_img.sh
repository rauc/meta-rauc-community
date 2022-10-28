#!/bin/sh

#function manage to display Error message and exit 
Error(){
    echo "[ ERROR ] : $1"
    exit 1
}


file="sd.img"

#check if parameters were set
[ "$#" -eq "0" ] && Error "No parameters were set"

#path of core-image-minimal-qemuarma9.wic
#where it suppose to be

path_of_wic_file="$1"

[ ! -d "$path_of_wic_file" ] && Error "Path $path_of_wic_file doesn't exist"

[ ! -f "$path_of_wic_file/core-image-minimal-qemuarma9.wic" ] && Error "File $path_of_wic_file/core-image-minimal-qemuarma9.wic doesn't exist"

echo "$0 : go to path ${path_of_wic_file}"

cd "$path_of_wic_file"


if [ -f "$file" ] ; then
    
    echo "$0 : Removing old sd.img"
    rm "$file"
fi


echo "$0 : Creating empty sd.img file"
dd if=/dev/zero of=sd.img bs=1M count=2000
echo "$0 : Copying content from wic file"
dd if=core-image-minimal-qemuarma9.wic of=sd.img conv=notrunc

echo "Resize rootfs partition to take the whole sd.img size"
parted -s sd.img resizepart 2 100%
exit 0



