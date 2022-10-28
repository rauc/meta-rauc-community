FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://fw_env.config"

do_install_append() {
	install -d ${D}${sysconfdir}
	cp  ${WORKDIR}/fw_env.config	${D}${sysconfdir}
}	

