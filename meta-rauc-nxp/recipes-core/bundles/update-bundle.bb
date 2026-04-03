DESCRIPTION = "RAUC bundle generator"

inherit bundle

# Allow selection of the bundle rather than hardcoding it
BUNDLE_IMAGE_NAME ?= "core-image-base"

RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_COMPATIBLE = "${MACHINE}"
RAUC_BUNDLE_VERSION = "v20260328"
RAUC_BUNDLE_DESCRIPTION = "RAUC demonstration bundle"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "${BUNDLE_IMAGE_NAME}"
RAUC_SLOT_rootfs[fstype] = "ext4"

RAUC_KEY_FILE ?= "${THISDIR}/files/development-1.key.pem"
RAUC_CERT_FILE ?= "${THISDIR}/files/development-1.cert.pem"

#---------------------------------------------------
# Everything here and below is a conditional support
# for having dual boot partition as well.
#---------------------------------------------------
RAUC_BUNDLE_SLOTS:append:rauc-ab-bootrootfs = " boot"
RAUC_SLOT_boot:rauc-ab-bootrootfs = "${BUNDLE_IMAGE_NAME}"

#
# Dynamic file naming based on the overrides
# The only reason for this function is to keep the previous behavior working for the other iMX products. It would be much more elegant to have another layer.
# It is not possible to both use the dictionary and an override together (e.g. as in RAUC_SLOT_boot:... and RAUC_BUNDLE_SLOTS:... above.
#
python () {
    # Do something like
    #  RAUC_SLOT_boot:rauc-ab-bootrootfs[fstype] = "boot.vfat"
    #  RAUC_SLOT_boot:rauc-ab-bootrootfs[file] = "${BUNDLE_IMAGE_NAME}-${MACHINE}.boot.vfat"
    # But legally
    overrides = d.getVar('OVERRIDES').split(':')
    if 'rauc-ab-bootrootfs' not in overrides:
        return

    machine = d.getVar('MACHINE')
    img     = d.getVar('BUNDLE_IMAGE_NAME')
    d.setVarFlag('RAUC_SLOT_boot', 'fstype', 'boot.vfat')
    d.setVarFlag('RAUC_SLOT_boot', 'file',   f'{img}-{machine}.boot.vfat')
}
