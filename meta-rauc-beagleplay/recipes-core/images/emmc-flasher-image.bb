SUMMARY = "A small SD card image to flash the eMMC"

#IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

IMAGE_FSTYPES += "wic wic.xz wic.bmap ext4"
IMAGE_BOOT_FILES += " boot.scr"

IMAGE_INSTALL:append = " emmc-flasher"
