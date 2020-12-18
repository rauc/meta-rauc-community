inherit rauc-integration

FILESEXTRAPATHS_prepend_rauc-integration := "${THISDIR}/files:"
SRC_URI_append_rauc-integration = " file://boot.cmd.in"
