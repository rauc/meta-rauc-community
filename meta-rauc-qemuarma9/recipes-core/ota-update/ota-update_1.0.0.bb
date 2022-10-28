DESCRIPTION = "Simple ota update application"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LICENSE = "GPLv3"

LIC_FILES_CHKSUM = "file://LICENSE;md5=05db1bbd0c96a60195fc553d920fc6cd"

RDEPENDS_${PN} = "imgversion ota-update wget e2fsprogs e2fsprogs-resize2fs"

SRC_URI = "file://ota_update.c \
           file://ota_update.h \
           file://LICENSE"

S = "${WORKDIR}"

do_compile() {
	${CC} ${LDFLAGS} ota_update.c -o ota_update
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ota_update ${D}${bindir}
}
