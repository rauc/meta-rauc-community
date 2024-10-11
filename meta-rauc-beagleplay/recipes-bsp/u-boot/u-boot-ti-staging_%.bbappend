FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "  \
    file://configure-for-rauc.cfg \
"
# Add these for the A53 only, otherwise the multiconfig setup of R5 and A53 will
# attempt to create boot.scr in DEPLOY_DIR_IMAGE, triggering a file conflict.
SRC_URI:append:aarch64 = " file://fw_env.config file://boot.cmd"

# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX:aarch64 = "scr"
UBOOT_ENV:aarch64 = "boot"

