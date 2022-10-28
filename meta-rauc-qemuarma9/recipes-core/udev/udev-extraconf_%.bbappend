FILESEXTRAPATHS_prepend_rpi := "${THISDIR}/files:"
SRC_URI_append_rpi = " file://rauc.rules"

do_install_append_rpi() {
    install -m 0644 ${WORKDIR}/rauc.rules ${D}${sysconfdir}/udev/mount.blacklist.d/
}
