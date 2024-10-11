FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add a mount point for a shared data partition
dirs755 += "/data"

FILES:${PN} += "/uboot"

do_install:append() {
    mkdir ${D}/uboot
}
