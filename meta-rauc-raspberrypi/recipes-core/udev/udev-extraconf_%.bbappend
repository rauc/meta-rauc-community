FILESEXTRAPATHS:prepend:rpi := "${THISDIR}/files:"
SRC_URI:append:rpi = " file://raspberrypi-rauc.rules"

do_install:append:rpi() {
    install -m 0644 ${WORKDIR}/raspberrypi-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
