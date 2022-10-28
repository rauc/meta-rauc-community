FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://rauc.cfg"
SRC_URI += "file://graphics.cfg"

CMDLINE_remove = "root=/dev/mmcblk0p2"

# WR qemuarma9 configuration, not supported in Yocto
KBRANCH_qemuarma9 ?= "v5.4/standard/arm-versatile-926ejs"
KMACHINE_qemuarma9 ?= "qemuarma9"
KERNEL_DEVICETREE_qemuarma9 = "vexpress-v2p-ca9.dtb"
COMPATIBLE_MACHINE_qemuarma9 = "qemuarma9"
