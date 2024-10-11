SUMMARY = "Basic flasher for eMMC"

LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${WORKDIR}/emmc-flasher.init;beginline=13;endline=13;md5=d0eaae3a9dd686c6772b935fdc4d7143"

SRC_URI = "file://emmc-flasher.init"

inherit update-rc.d
INITSCRIPT_NAME = "emmc-flasher"
INITSCRIPT_PARAMS = "start 99 5 ."

EMMC_FLASHER_IMAGE ?= "core-image-minimal"

FILES:${PN} = " \
    ${sysconfdir}/init.d/emmc-flasher \
    /emmc-image.wic.xz \
"

do_install[depends] += "${EMMC_FLASHER_IMAGE}:do_image_complete"

do_install() {
    cp -L ${DEPLOY_DIR_IMAGE}/${EMMC_FLASHER_IMAGE}-${MACHINE}.rootfs.wic.xz ${D}/emmc-image.wic.xz
    install -m 755 -D ${WORKDIR}/emmc-flasher.init ${D}${sysconfdir}/init.d/emmc-flasher
}
