FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := "  \
	file://system.conf \
	file://ca.cert.pem \
"

# additional dependencies required to run RAUC on the target
RDEPENDS:${PN} += "u-boot-fw-utils u-boot-tegra-env"

do_install:prepend () {
	sed -i "s|@@MACHINE@@|${MACHINE}|g" ${WORKDIR}/system.conf
}
