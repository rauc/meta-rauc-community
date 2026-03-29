# Store the kernel in the rootfs partition
IMAGE_INSTALL:append = " kernel-image kernel-modules"

# Remove the kernel from the /boot partition because it is in rootfs
RPI_EXTRA_IMAGE_BOOT_FILES:remove = "${KERNEL_IMAGETYPE}"

IMAGE_INSTALL:append = " rpi-eeprom"
IMAGE_INSTALL:append = " rpi-autoboot"
IMAGE_FSTYPES:remove = " ext3"
IMAGE_FSTYPES:append = " ext4"

WKS_FILE = "sdimage-dual-raspberrypi.wks.in"

# the root/boot partitions are passed in as kernel-cmdline parameters
WIC_CREATE_EXTRA_ARGS = " --no-fstab-update"

# for the bundle to have the slot images available, we need to have wic also deploy the separate partition images
# see: https://github.com/gportay/meta-downstream/blob/master/meta-rauc-raspberrypi-firmware/recipes-core/images/core-image-minimal.bbappend
IMAGE_CMD:wic:append() {
    basename="$(basename "${wks%.wks}")"
    cp "$build_wic/$basename-"*".direct.p2" "$out-p2.img"
    ln -sf ${IMAGE_NAME}-p2.img "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-p2.img"
    cp "$build_wic/$basename-"*".direct.p5" "$out-p5.img"
    ln -sf ${IMAGE_NAME}-p5.img "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-p5.img"
}
