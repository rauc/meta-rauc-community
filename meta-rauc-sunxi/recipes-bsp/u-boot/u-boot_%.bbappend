FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += " bc-native dtc-native swig-native python3-native flex-native bison-native "
DEPENDS:append_sun50i = " atf-sunxi "

COMPATIBLE_MACHINE = "(sun4i|sun5i|sun7i|sun8i|sun50i)"

DEFAULT_PREFERENCE:sun4i = "1"
DEFAULT_PREFERENCE:sun5i = "1"
DEFAULT_PREFERENCE:sun7i = "1"
DEFAULT_PREFERENCE:sun8i = "1"
DEFAULT_PREFERENCE:sun50i = "1"

SRC_URI += " \
    file://fw_env.config \
    file://boot.cmd.in \
"

UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"

EXTRA_OEMAKE += ' HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}" '
EXTRA_OEMAKE:append:sun50i = " BL31=${DEPLOY_DIR_IMAGE}/bl31.bin "

do_compile_sun50i[depends] += "atf-sunxi:do_deploy"

do_compile:append() {
    ${B}/tools/mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd.in ${WORKDIR}/${UBOOT_ENV_BINARY}
}

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}


