tar --transform='flags=r;s|zImage|kernel|' --transform='flags=r;s|core-image-minimal-qemuarma9.ext4|rootfs.ext4|' -cjf $1.tar.bz2 core-image-minimal-qemuarma9.ext4 zImage -h
