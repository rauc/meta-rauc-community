# ---
# Out-of-tree device tree for the qemuarm/qemuarm64 machines.
#
# As we don't boot the kernel directly from QEMU (instead u-boot does)
# and more control of the DT may be useful, this package provides the DT
# as dumped by QEMU (using the '-machine dumpdtb=<name>.dtb' option).

SUMMARY = "Provides an out-of-tree devicetree for the qemuarm/qemuarm64 machine."

inherit devicetree

SRC_URI:qemuarm = "file://qemuarm.dts"
SRC_URI:qemuarm64 = "file://qemuarm64.dts"

COMPATIBLE_MACHINE = "^(qemuarm|qemuarm64)$"
