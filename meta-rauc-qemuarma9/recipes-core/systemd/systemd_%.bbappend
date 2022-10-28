PACKAGECONFIG_append = " networkd resolved"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

MY_INTERFACE = "eth0"
ID_NUM = "10"

SRC_URI += " \
    file://${ID_NUM}-${MY_INTERFACE}.network \
    file://${ID_NUM}-${MY_INTERFACE}.link \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/${ID_NUM}-${MY_INTERFACE}.network \
    ${sysconfdir}/systemd/network/${ID_NUM}-${MY_INTERFACE}.link \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/${ID_NUM}-${MY_INTERFACE}.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/${ID_NUM}-${MY_INTERFACE}.link ${D}${sysconfdir}/systemd/
}
