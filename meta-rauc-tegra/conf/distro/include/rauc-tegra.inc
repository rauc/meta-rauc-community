# Distro settings required for RAUC A/B updates on the Jetson Orin NX and Orin
# Nano machines (rauc-tegra machine override, see conf/layer.conf).
#
# Opt in from your distro configuration (recommended) or from local.conf:
#
#   require conf/distro/include/rauc-tegra.inc

DISTRO_FEATURES:append = " rauc"
IMAGE_INSTALL:append = " rauc"

# The recipes of this layer apply to the machines carrying the "rauc-tegra"
# override: the Jetson modules whose TEGRA_BOARDID is listed below (3767: Orin
# NX and Orin Nano, on any carrier board). It is prepended, so it has the
# lowest priority of the machine overrides.
RAUC_TEGRA_BOARDIDS ??= "3767"
MACHINEOVERRIDES:prepend = "${@'rauc-tegra:' if (d.getVar('TEGRA_BOARDID') or '') in (d.getVar('RAUC_TEGRA_BOARDIDS') or '').split() else ''}"

# The ext4 rootfs image is the content of the update bundle.
IMAGE_FSTYPES:append:rauc-tegra = " ext4"

# A/B flash layout (APP / APP_b), required by the slot layout of system.conf.
USE_REDUNDANT_FLASH_LAYOUT_DEFAULT:rauc-tegra = "1"

# The SD card image does not format the DATA partition at flash time
IMAGE_INSTALL:append:jetson-orin-nano-devkit = " e2fsprogs-mke2fs"
