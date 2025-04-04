FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://sunxi-rauc.rules"

do_install:append() {
    install -m 0644 ${UNPACKDIR}/sunxi-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
