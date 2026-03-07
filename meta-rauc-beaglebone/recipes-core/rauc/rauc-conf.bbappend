FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_install:prepend() {
	sed -i "s/@@MACHINE@@/${MACHINE}/g" ${UNPACKDIR}/system.conf
}
