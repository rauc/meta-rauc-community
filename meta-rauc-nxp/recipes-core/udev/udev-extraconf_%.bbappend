FILESEXTRAPATHS:prepend:cubox-i := "${THISDIR}/files:"
SRC_URI:append:cubox-i = " file://cubox-i-rauc.rules"

do_install:append:cubox-i() {
    install -m 0644 ${WORKDIR}/cubox-i-rauc.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}


FILESEXTRAPATHS:prepend:rauc-ab-bootrootfs := "${THISDIR}/files:"
SRC_URI:append:rauc-ab-bootrootfs = " file://rauc-ab-bootrootfs.rules"

do_install:append:rauc-ab-bootrootfs() {
    install -m 0644 ${WORKDIR}/rauc-ab-bootrootfs.rules ${D}${sysconfdir}/udev/mount.ignorelist.d/
}

