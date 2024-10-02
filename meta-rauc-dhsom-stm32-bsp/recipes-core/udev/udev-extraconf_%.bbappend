FILESEXTRAPATHS:prepend:dh-stm32mp13-dhcor-dhsbc := "${THISDIR}/files:"
SRC_URI:append:dh-stm32mp13-dhcor-dhsbc = " file://dhsom-stm32-rauc.rules"

do_install:append:dh-stm32mp13-dhcor-dhsbc() {
    install -m 0644 ${WORKDIR}/dhsom-stm32-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
