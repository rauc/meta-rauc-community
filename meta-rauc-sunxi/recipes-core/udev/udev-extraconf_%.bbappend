FILESEXTRAPATHS:prepend:sun8i := "${THISDIR}/files:"
SRC_URI:append:sun8i = " file://sunxi-rauc.rules"

do_install:append:sun8i() {
    install -m 0644 ${WORKDIR}/sunxi-rauc.rules ${D}${sysconfdir}/udev/mount.blacklist.d/
}
