FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://bbb-rauc.rules"

do_install:append() {
    install -m 0644 ${UNPACKDIR}/bbb-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
