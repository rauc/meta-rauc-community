DESCRIPTION = "RAUC bundle generator"

inherit bundle

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"
RAUC_BUNDLE_VERSION = "v20240627"
RAUC_BUNDLE_DESCRIPTION = "RAUC demonstration bundle"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-base"
RAUC_SLOT_rootfs[fstype] = "ext4"
