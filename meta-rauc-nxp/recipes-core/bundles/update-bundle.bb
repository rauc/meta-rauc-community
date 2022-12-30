DESCRIPTION = "RAUC bundle generator"

inherit bundle

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_COMPATIBLE = "Cubox-i/Hummingboard RAUC example"
RAUC_BUNDLE_VERSION = "v20221214"
RAUC_BUNDLE_DESCRIPTION = "RAUC demonstration bundle"
RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "ext4"

