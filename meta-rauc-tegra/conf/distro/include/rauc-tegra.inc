# Distro settings required for RAUC A/B updates on the Jetson Orin Nano devkits (jetson-orin-nano-devkit and jetson-orin-nano-devkit-nvme).
#
# Opt in from your distro configuration (recommended) or from local.conf:
#
#   require conf/distro/include/rauc-tegra.inc

DISTRO_FEATURES:append = " rauc"
IMAGE_INSTALL:append = " rauc"

# The ext4 rootfs image is the content of the update bundle.
IMAGE_FSTYPES:append:jetson-orin-nano-devkit = " ext4"

# A/B flash layout (APP / APP_b), required by the slot layout of system.conf.
USE_REDUNDANT_FLASH_LAYOUT_DEFAULT:jetson-orin-nano-devkit = "1"

# The SD card image does not format the DATA partition at flash time
IMAGE_INSTALL:append:jetson-orin-nano-devkit = " e2fsprogs-mke2fs"
