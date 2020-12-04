FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit rauc-integration

SRC_URI_append_rauc-integration = " file://boot.cmd.in"
