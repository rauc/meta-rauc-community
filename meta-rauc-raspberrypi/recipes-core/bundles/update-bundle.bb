DESCRIPTION = "RAUC bundle generator"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"
RAUC_BUNDLE_VERSION = "v20200703"
RAUC_BUNDLE_DESCRIPTION = "RAUC Demo Bundle"

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "ext4"
