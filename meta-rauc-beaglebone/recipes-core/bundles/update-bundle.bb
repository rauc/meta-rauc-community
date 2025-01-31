DESCRIPTION = "RAUC bundle generator"

inherit bundle

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"


RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_COMPATIBLE = "BeagleBoneBlack"
RAUC_BUNDLE_VERSION = "v20240123"
RAUC_BUNDLE_DESCRIPTION = "RAUC demonstration bundle"
RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "ext4"
