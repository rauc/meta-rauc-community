FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rauc.cfg"

KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/rauc.cfg"
