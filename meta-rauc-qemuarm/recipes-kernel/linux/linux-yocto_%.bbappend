# ---
# qemuarm specific kernel extensions and configurations
#
# This also injects the kernel configuration required to interact with the bootloader environment.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://mtd_flash.cfg"
SRC_URI:append:qemuarm = " file://qemuarm.dts"
SRC_URI:append:qemuarm64 = " file://qemuarm64.dts"


# Architecture specific kernel configuration
KERNEL_DEVICETREE:qemuarm = "qemuarm.dtb"
KERNEL_DEVICETREE:qemuarm64 = "qemuarm64.dtb"
KERNEL_EXTRA_ARGS:qemuarm += "LOADADDR=${UBOOT_ENTRYPOINT}"
KERNEL_EXTRA_ARGS:qemuarm64 += "LOADADDR=${UBOOT_ENTRYPOINT}"

# Instead of patching the DTS into the kernel tree, copy it to allow easier modification of the file.
do_configure:append:qemuarm() {
    cp ${UNPACKDIR}/qemuarm.dts ${S}/arch/arm/boot/dts
    echo "dtb-$(CONFIG_ARCH_QEMU) += qemuarm.dtb" >> ${S}/arch/arm/boot/dts/Makefile
}

do_configure:append:qemuarm64() {
    cp ${UNPACKDIR}/qemuarm64.dts ${S}/arch/arm64/boot/dts
    echo "dtb-$(CONFIG_ARCH_QEMU) += qemuarm64.dtb" >> ${S}/arch/arm64/boot/dts/Makefile
}