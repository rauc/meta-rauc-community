FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://boot.cmd \
	file://0001-configs-rock-pi-4-rk3399_defconfig-RAUC.patch \
"

# The UBOOT_ENV_SUFFIX and UBOOT_ENV are mandatory in order to run the
# uboot-mkimage command from poky/meta/recipes-bsp/u-boot/u-boot.inc
UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"

FILES:${PN}-extlinux += "/boot/${UBOOT_ENV_BINARY}"
