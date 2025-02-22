FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://fw_env.config \
"

do_install:append () {
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/
}
