# ---
# qemuarm specific kernel extensions and configurations
#
# Provides the kernel configuration required to interact with the bootloader environment.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://mtd_flash.cfg"

# Architecture specific kernel configuration
KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"