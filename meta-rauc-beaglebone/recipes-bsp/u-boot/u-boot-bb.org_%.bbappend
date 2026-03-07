FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:pocketbeagle2 = "  \
    file://fw_env.config \
    file://boot.cmd \
"

# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX:pocketbeagle2 = "scr"
UBOOT_ENV:pocketbeagle2 = "boot"

do_install:append:pocketbeagle2() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}
