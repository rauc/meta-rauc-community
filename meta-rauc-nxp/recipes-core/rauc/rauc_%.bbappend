FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := " file://system.conf"

RDEPENDS:${PN} += "u-boot-fw-utils"
DEPENDS += "u-boot-fslc"

