FILESEXTRAPATHS_prepend_sun8i := "${THISDIR}/files:"
SRC_URI_append_sun8i = " file://sunxi-rauc.rules"

do_install_append_sun8i() {
    install -m 0644 ${WORKDIR}/sunxi-rauc.rules ${D}${sysconfdir}/udev/mount.blacklist.d/
}
