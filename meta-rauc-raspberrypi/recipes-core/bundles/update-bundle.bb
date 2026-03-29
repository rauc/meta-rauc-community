DESCRIPTION = "RAUC bundle generator"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"
RAUC_BUNDLE_VERSION = "v20200703"
RAUC_BUNDLE_DESCRIPTION = "RAUC Demo Bundle"

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "firmware rootfs"

RAUC_SLOT_firmware = "core-image-minimal"
RAUC_SLOT_firmware[file] = "core-image-minimal-${MACHINE}.rootfs-p2.img"
RAUC_SLOT_firmware[fstype] = "ext4"
RAUC_SLOT_firmware[rename] = "firmware.vfat"

RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[file] = "core-image-minimal-${MACHINE}.rootfs.ext4"
RAUC_SLOT_rootfs[fstype] = "ext4"
RAUC_SLOT_rootfs[rename] = "rootfs.ext4"
