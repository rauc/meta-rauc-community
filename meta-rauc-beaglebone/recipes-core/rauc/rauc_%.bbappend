FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "  \
	file://rauc-grow-data-partition.service \
	file://grow-data-partition.sh \
"

# additional dependencies required to run RAUC on the target
RDEPENDS:${PN} += "u-boot-fw-utils"

RDEPENDS:${PN}:append:beaglebone-yocto = " u-boot-env"
RDEPENDS:${PN}:append:beaglebone = " u-boot-bb.org-env"
RDEPENDS:${PN}:append:pocketbeagle2 = " u-boot-bb.org-env"

inherit systemd

SYSTEMD_PACKAGES += "${PN}-grow-data-part"
SYSTEMD_SERVICE:${PN}-grow-data-part = "rauc-grow-data-partition.service"

PACKAGES += "rauc-grow-data-part"

RDEPENDS:${PN}-grow-data-part += "parted e2fsprogs-resize2fs gptfdisk"

DATADEV:beaglebone-yocto = "mmcblk0"
DATADEV:beaglebone = "mmcblk0"
DATADEV:pocketbeagle2 = "mmcblk1"

do_install:append() {
	sed -i "s/@@DATADEV@@/${DATADEV}/g" ${UNPACKDIR}/grow-data-partition.sh

	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${UNPACKDIR}/rauc-grow-data-partition.service ${D}${systemd_unitdir}/system/

	install -d ${D}/${bindir}
	install -m 0755 ${UNPACKDIR}/grow-data-partition.sh ${D}/${bindir}
}
