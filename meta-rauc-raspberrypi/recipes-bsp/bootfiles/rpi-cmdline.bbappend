FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Will be set from the A/B specific cmdline_*.txt files instead
CMDLINE_ROOTFS = ""

# Provide A/B specific cmdline files to be used with [boot_partition=N] filter
do_compile:append () {
    echo "root=/dev/mmcblk0p5 ${CMDLINE_ROOT_FSTYPE} rootwait systemd.mount-extra=/dev/mmcblk0p2:/boot:vfat" > "${WORKDIR}/cmdline-rootfs-A.txt"
    echo "root=/dev/mmcblk0p6 ${CMDLINE_ROOT_FSTYPE} rootwait systemd.mount-extra=/dev/mmcblk0p3:/boot:vfat" > "${WORKDIR}/cmdline-rootfs-B.txt"
}

do_deploy:append() {
    install -m 0644 "${WORKDIR}/cmdline-rootfs-A.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
    install -m 0644 "${WORKDIR}/cmdline-rootfs-B.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
}
