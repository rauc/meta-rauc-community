FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_compile:append() {
	mkimage -C none -A ${UBOOT_ARCH} -T script -d ${UBOOT_EXTLINUX_BOOTSCR} ${UBOOT_EXTLINUX_BOOTSCR_IMG}
}
