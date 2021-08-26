FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://rauc.cfg"
CMDLINE:remove = "root=/dev/mmcblk0p2"
