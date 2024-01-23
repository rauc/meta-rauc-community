IMAGE_FSTYPES += "wic wic.xz wic.bmap ext4"
WKS_FILE = "beaglebone-yocto-dual.wks.in"
IMAGE_BOOT_FILES += " boot.scr"

# Optimizations for RAUC adaptive method 'block-hash-index'
# rootfs image size must to be 4K-aligned
IMAGE_ROOTFS_ALIGNMENT = "4"
# ext4 block and inode size should be set to 4K
EXTRA_IMAGECMD:ext4 = "-i 4096 -b 4096"
