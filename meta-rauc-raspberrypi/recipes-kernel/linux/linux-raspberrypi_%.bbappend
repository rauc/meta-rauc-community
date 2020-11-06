FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://rauc.cfg"
CMDLINE_remove = "root=/dev/mmcblk0p2"
