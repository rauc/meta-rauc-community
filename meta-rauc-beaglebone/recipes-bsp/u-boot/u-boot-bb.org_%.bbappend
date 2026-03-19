FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Explicitly set SRC_URI and UBOOT_ENV variables for supported machines
# to avoid issues caused by meta-ti and MACHINE:append = "-k3r5" that
# result in "No such file or directory" and similar errors.

SRC_URI:append:pocketbeagle2 = "  \
    file://fw_env.config \
    file://boot.cmd \
"

SRC_URI:append:beaglebone-ai64 = "  \
    file://fw_env.config \
    file://boot.cmd \
    file://bootcmd-ti-mmc.cfg \
"

SRC_URI:append:beaglebone = " \
    file://fw_env.config \
    file://boot.cmd \
    file://bootcmd-ti-mmc.cfg \
"

# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX:beaglebone = "scr"
UBOOT_ENV:beaglebone = "boot"
UBOOT_ENV_SUFFIX:pocketbeagle2 = "scr"
UBOOT_ENV:pocketbeagle2 = "boot"
UBOOT_ENV_SUFFIX:beaglebone-ai64 = "scr"
UBOOT_ENV:beaglebone-ai64 = "boot"

do_install_fw_env_config() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

do_install:append:beaglebone() {
    do_install_fw_env_config
}

do_install:append:pocketbeagle2() {
    do_install_fw_env_config
}

do_install:append:beaglebone-ai64() {
    do_install_fw_env_config
}
