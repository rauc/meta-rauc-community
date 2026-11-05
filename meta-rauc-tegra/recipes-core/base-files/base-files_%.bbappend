# Mount point and fstab entry for the persistent DATA partition (see recipes-bsp/tegra-binaries/tegra-storage-layout_%.bbappend).

DATA_PART_NAME ?= "DATA"
DATA_MOUNT_POINT ?= "/data"

# With a flashed data image (RAUC_TEGRA_DATAIMG_SIZE_MB, see classes/rauc-dataimg-tegra.bbclass) the filesystem is smaller than the fill-to-end partition: grow it at mount time (systemd-growfs, online ext4 resize). makefs only acts when the partition has no filesystem.
RAUC_TEGRA_DATAIMG_SIZE_MB ?= ""
DATA_PART_GROWFS ?= "${@'1' if d.getVar('RAUC_TEGRA_DATAIMG_SIZE_MB') else '0'}"
DATA_MOUNT_OPTIONS ?= "defaults,nofail,x-systemd.makefs${@',x-systemd.growfs' if d.getVar('DATA_PART_GROWFS') == '1' else ''},x-systemd.device-timeout=30s"

do_install:append:jetson-orin-nano-devkit() {
    install -d ${D}${DATA_MOUNT_POINT}
    echo "/dev/disk/by-partlabel/${DATA_PART_NAME}  ${DATA_MOUNT_POINT}  ext4  ${DATA_MOUNT_OPTIONS}  0  0" >> ${D}${sysconfdir}/fstab
}

FILES:${PN}:append:jetson-orin-nano-devkit = " ${DATA_MOUNT_POINT}"
