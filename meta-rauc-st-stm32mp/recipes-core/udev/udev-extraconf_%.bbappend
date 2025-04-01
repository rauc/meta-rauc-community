FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://rauc.rules"

do_install:append() {
    install -m 0644 ${WORKDIR}/rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}
