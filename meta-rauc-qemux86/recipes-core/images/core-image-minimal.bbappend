IMAGE_INSTALL:append = " kernel-image kernel-modules"

IMAGE_FSTYPES += "wic ext4"
WKS_FILE = "qemux86-grub-efi.wks"
do_image_wic[depends] += "boot-image:do_deploy"

# Optimizations for RAUC adaptive method 'block-hash-index'
# rootfs image size must to be 4K-aligned
IMAGE_ROOTFS_ALIGNMENT = "4"
# ext4 block size should be set to 4K and use a fixed directory hash seed to
# reduce the image delta size (keep oe-core's 4K bytes-per-inode)
EXTRA_IMAGECMD:ext4 = "-i 4096 -b 4096 -E hash_seed=86ca73ff-7379-40bd-a098-fcb03a6e719d"
