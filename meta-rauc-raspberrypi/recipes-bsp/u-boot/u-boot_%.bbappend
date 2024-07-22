FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:rpi = " \
    file://rpi_arm64_defconfig.patch \
"