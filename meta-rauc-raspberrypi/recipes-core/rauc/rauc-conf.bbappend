FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := " file://ca.cert.pem "

do_install:prepend() {
	sed -i "s/@@MACHINE@@/${MACHINE}/g" ${S}/system.conf
}
