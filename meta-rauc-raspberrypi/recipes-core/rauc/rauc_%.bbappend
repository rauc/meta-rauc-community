# hack... hack...
# to get the new "bootloader=raspberrypi"
SRC_URI = "git://github.com/Rtone/rauc.git;protocol=https;branch=bootchooser-add-raspberrypi-firmware-initial-support"
SRCREV = "f6b5f54bb717cf8d38a6c4ff82159e7b1e655d61"
LIC_FILES_CHKSUM = "file://COPYING;md5=4bf661c1e3793e55c8d1051bc5e0ae21"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := "  \
	file://rauc-grow-data-partition.service \
"

# additional dependencies required to run RAUC on the target
#RDEPENDS:${PN} += "u-boot-fw-utils u-boot-env"
RDEPENDS:${PN} += "raspi-utils"

inherit systemd

SYSTEMD_PACKAGES += "${PN}-grow-data-part"
SYSTEMD_SERVICE:${PN}-grow-data-part = "rauc-grow-data-partition.service"

PACKAGES += "rauc-grow-data-part"

RDEPENDS:${PN}-grow-data-part += "parted"

do_install:append() {
	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${UNPACKDIR}/rauc-grow-data-partition.service ${D}${systemd_unitdir}/system/
}
