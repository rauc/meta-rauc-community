# ---
# qemuarm specific kernel extensions and configurations
#
# This also injects the kernel configuration required to interact with the bootloader environment.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://qemuarm.dts \
    file://mtd_flash.cfg \
"

# Architecture specific kernel configuration
KERNEL_IMAGETYPE:qemuarm = "zImage"
KERNEL_DEVICETREE:qemuarm = "qemuarm.dtb"
KERNEL_EXTRA_ARGS:qemuarm += "LOADADDR=${UBOOT_ENTRYPOINT}"

# Instead of patching the DTS into the kernel tree, copy it to allow easier modification of the file.
do_configure:append() {
    cp ${UNPACKDIR}/qemuarm.dts ${S}/arch/arm/boot/dts
    echo "dtb-$(CONFIG_ARCH_QEMU) += qemuarm.dtb" >> ${S}/arch/arm/boot/dts/Makefile
}