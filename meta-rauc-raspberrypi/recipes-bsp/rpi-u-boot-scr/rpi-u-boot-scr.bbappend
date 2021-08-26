inherit rauc-integration

FILESEXTRAPATHS:prepend:rauc-integration := "${THISDIR}/files:"
SRC_URI:append:rauc-integration = " file://boot.cmd.in"
