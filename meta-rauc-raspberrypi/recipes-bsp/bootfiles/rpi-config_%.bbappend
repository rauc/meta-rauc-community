FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# see https://www.raspberrypi.com/documentation/computers/config_txt.html#the-boot_partitionn-filter
RPI_EXTRA_CONFIG = "\n\
[boot_partition=2]\n\
cmdline=cmdline-rootfs-A.txt\n\
\n\
[boot_partition=3]\n\
cmdline=cmdline-rootfs-B.txt\n\
"
