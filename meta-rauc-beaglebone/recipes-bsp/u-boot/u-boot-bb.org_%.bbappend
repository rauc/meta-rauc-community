FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "  \
    file://fw_env.config \
    file://boot.cmd \
"

SRC_URI:append:beaglebone = " file://bootcmd-ti-mmc.cfg"

# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"

do_install:append() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}
