LICENSE="GPLv3"

do_install() {
	install -d ${D}${sysconfdir}
	echo "${IMAGE_VERSION}" > ${D}${sysconfdir}/image_version
}

