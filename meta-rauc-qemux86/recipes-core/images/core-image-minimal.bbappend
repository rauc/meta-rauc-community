IMAGE_INSTALL:append = " kernel-image kernel-modules"

IMAGE_FSTYPES += "wic"
WKS_FILE = "qemux86-grub-efi.wks"
do_image_wic[depends] += "boot-image:do_deploy"

# Optimizations for RAUC adaptive method 'block-hash-index'
# rootfs image size must to be 4K-aligned
IMAGE_ROOTFS_ALIGNMENT = "4"
# ext4 block and inode size should be set to 4K
EXTRA_IMAGECMD:ext4 = "-i 4096 -b 4096"
