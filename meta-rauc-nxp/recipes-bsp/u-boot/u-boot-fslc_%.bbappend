FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "  \
    file://boot.cmd \
    file://fw_env.config \
"

DEPENDS += "u-boot-mkimage-native"
PROVIDES += "u-boot-default-script"


DEPENDS += "bc-native dtc-native swig-native python3-native flex-native bison-native"
EXTRA_OEMAKE += 'HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}"'


UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"


do_compile:append() {
    mkimage -A ${UBOOT_ARCH} -T script -C none -d "${WORKDIR}/boot.cmd" ${WORKDIR}/${UBOOT_ENV_BINARY}
}

do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}


do_deploy:append() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}
}

