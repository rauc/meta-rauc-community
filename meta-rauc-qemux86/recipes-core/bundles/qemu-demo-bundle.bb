inherit bundle

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

RAUC_BUNDLE_COMPATIBLE = "qemux86-64 demo platform"

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "efi rootfs"

RAUC_IMAGE_FSTYPE = "tar.bz2"

RAUC_SLOT_rootfs = "core-image-minimal"
# uncomment for enabling adaptive update method 'block-hash-index'
#RAUC_SLOT_rootfs[fstype] = "ext4"
#RAUC_SLOT_rootfs[adaptive] = "block-hash-index"

RAUC_SLOT_efi = "boot-image"
RAUC_SLOT_efi[file] = "efi-boot.vfat"
RAUC_SLOT_efi[type] = "boot"
