FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := "  \
	file://rauc-grow-data-partition.service \
	file://grow-data-partition.sh \
"

# additional dependencies required to run RAUC on the target
RDEPENDS:${PN} += "u-boot-fw-utils u-boot-env"

inherit systemd

SYSTEMD_PACKAGES += "${PN}-grow-data-part"
SYSTEMD_SERVICE:${PN}-grow-data-part = "rauc-grow-data-partition.service"

PACKAGES += "rauc-grow-data-part"

RDEPENDS:${PN}-grow-data-part += "parted e2fsprogs-resize2fs gptfdisk"

do_install:append() {
	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${UNPACKDIR}/rauc-grow-data-partition.service ${D}${systemd_unitdir}/system/

	install -d ${D}/${bindir}
	install -m 0755 ${UNPACKDIR}/grow-data-partition.sh ${D}/${bindir}
}
