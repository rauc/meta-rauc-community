SUMMARY = "autoboot.txt for ROM loader A/B boot"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://autoboot.txt"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install () {
    install -d ${D}/autoboot
    install -m 0644 ${UNPACKDIR}/autoboot.txt ${D}/autoboot/autoboot.txt
}

FILES:${PN} = "/autoboot"
