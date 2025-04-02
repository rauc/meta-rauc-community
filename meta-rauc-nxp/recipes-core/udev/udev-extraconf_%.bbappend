FILESEXTRAPATHS:prepend:cubox-i := "${THISDIR}/files:"
SRC_URI:append:cubox-i = " file://cubox-i-rauc.rules"

do_install:append:cubox-i() {
    install -m 0644 ${UNPACKDIR}/cubox-i-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
