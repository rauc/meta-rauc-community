FILESEXTRAPATHS_prepend_rpi := "${THISDIR}/files:"
SRC_URI_append_rpi = " file://raspberrypi-rauc.rules"

do_install_append_rpi() {
    install -m 0644 ${WORKDIR}/raspberrypi-rauc.rules ${D}${sysconfdir}/udev/mount.blacklist.d/
}
