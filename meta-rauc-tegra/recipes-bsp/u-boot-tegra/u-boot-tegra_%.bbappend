FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:jetson-tx2-devkit = " \
    file://0001-include-configs-p2771-0000.h-Enable-RAUC.patch \
"

SRC_URI:append:jetson-nano-devkit-emmc = " \
    file://0001-include-configs-p3450-0000.h-Enable-RAUC.patch \
"

SRC_URI:append = " \
    file://0002-add-setexpr-cmd.patch \
"
