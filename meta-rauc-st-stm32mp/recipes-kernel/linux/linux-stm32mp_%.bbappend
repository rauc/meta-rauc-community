FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit rauc-integration

SRC_URI:append:rauc-integration = " file://rauc.config"

KERNEL_CONFIG_FRAGMENTS:append:rauc-integration = " ${WORKDIR}/rauc.config"
