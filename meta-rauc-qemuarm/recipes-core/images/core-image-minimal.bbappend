# ---
# Minor adjustments to the minimal image

IMAGE_INSTALL:append = " \
    u-boot-fw-utils \
    u-boot-default-env \
    kernel-image \
    devicetree-qemuarm \
    rauc \
    e2fsprogs-mke2fs \
    mtd-utils \
"

# Creating the bundle requires a tar archive, wic builds the full system image.
IMAGE_FSTYPES = "tar.bz2 wic.qcow2"

# Configure the bootimg-partition plugin to deploy the bootscript in the wic image
IMAGE_BOOT_FILES = "boot.scr"

WKS_FILE:qemuarm = "rauc-qemuarm.wks"
WKS_FILE:qemuarm64 = "rauc-qemuarm.wks"

do_image_wic[depends] += " \
    u-boot:do_deploy \
"