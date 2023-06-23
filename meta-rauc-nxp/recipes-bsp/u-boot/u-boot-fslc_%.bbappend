FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "  \
    file://boot.cmd \
    file://fw_env.config \
"

DEPENDS += "u-boot-mkimage-native"
PROVIDES += "u-boot-default-script"


DEPENDS += "bc-native dtc-native swig-native python3-native flex-native bison-native"
EXTRA_OEMAKE += 'HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}"'


# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"


do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}


do_deploy:append() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/${UBOOT_ENV_BINARY} ${DEPLOYDIR}
}

