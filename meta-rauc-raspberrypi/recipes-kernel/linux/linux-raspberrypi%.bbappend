FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit rauc-integration

SRC_URI_append_rauc-integration = " file://rauc.cfg"
CMDLINE_remove_rauc-integration = "root=/dev/mmcblk0p2"
