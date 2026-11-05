# Generate an ext4 data image for NVIDIA tegraflash packages.
#
# Projects can use this to provision persistent files outside the RAUC-managed
# rootfs slots during factory flashing. Files installed below ${IMAGE_ROOTFS}/data
# are moved into this image at the end of do_rootfs, so /data is empty in the
# rootfs image (and thus in the RAUC bundle).
#
# Enable it for the Jetson Orin Nano devkits by setting RAUC_TEGRA_DATAIMG_SIZE_MB
# globally (kas local_conf_header / local.conf) and inheriting this class in the
# image, e.g. IMAGE_CLASSES:append:pn-core-image-minimal = " rauc-dataimg-tegra".
# With RAUC_TEGRA_DATAIMG_SIZE_MB set, tegra-storage-layout_%.bbappend adds the
# DATAFILE filename entry to the DATA partition and base-files_%.bbappend adds
# x-systemd.growfs to its fstab entry. Do not inherit this class in initramfs
# images, which have no flash layout to carry the data image.

IMAGE_FSTYPES:append = " dataimg"
IMAGE_TYPEDEP:tegraflash:append = " dataimg"

# Size of the ext4 image in MiB. It must fit in the target flash partition.
RAUC_TEGRA_DATAIMG_SIZE_MB ?= ""
DATA_MOUNT_POINT ?= "/data"
RAUC_TEGRA_DATAIMG_LABEL ?= "data"
RAUC_TEGRA_DATAIMG_FSOPTS ?= ""

# Internal staging directory populated from ${IMAGE_ROOTFS}/data before mkfs.ext4.
RAUC_TEGRA_DATAIMG_POPULATE_DIR ?= "${WORKDIR}/dataimg-rootfs"

# Deploy symlink, per image so that several images do not share one link.
RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME ?= "${IMAGE_LINK_NAME}.dataimg"

IMAGE_CMD:dataimg() {
    if [ -z "${RAUC_TEGRA_DATAIMG_SIZE_MB}" ]; then
        bbfatal "RAUC_TEGRA_DATAIMG_SIZE_MB must be set to create dataimg"
    fi

    case "${RAUC_TEGRA_DATAIMG_SIZE_MB}" in
        *[!0-9]*)
            bbfatal "RAUC_TEGRA_DATAIMG_SIZE_MB must be an integer MiB value, got '${RAUC_TEGRA_DATAIMG_SIZE_MB}'"
            ;;
    esac

    if [ "${RAUC_TEGRA_DATAIMG_SIZE_MB}" -le 0 ]; then
        bbfatal "RAUC_TEGRA_DATAIMG_SIZE_MB must be greater than zero"
    fi

    img="${WORKDIR}/data.ext4"
    out="${IMGDEPLOYDIR}/${IMAGE_NAME}.dataimg"

    bbnote "Creating RAUC Tegra data image: ${out}, size=${RAUC_TEGRA_DATAIMG_SIZE_MB}MiB, label=${RAUC_TEGRA_DATAIMG_LABEL}"

    mkdir -p "${IMGDEPLOYDIR}"
    rm -f "$img" "$out"

    dd if=/dev/zero of="$img" count=0 bs=1M seek="${RAUC_TEGRA_DATAIMG_SIZE_MB}"

    mkfs_args="-F"

    if [ -n "${RAUC_TEGRA_DATAIMG_LABEL}" ]; then
        mkfs_args="$mkfs_args -L ${RAUC_TEGRA_DATAIMG_LABEL}"
    fi

    if [ -n "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}" ]; then
        if [ ! -d "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}" ]; then
            bbfatal "RAUC_TEGRA_DATAIMG_POPULATE_DIR does not exist: ${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
        fi
        mkfs_args="$mkfs_args -d ${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
    fi

    mkfs.ext4 \
        $mkfs_args \
        ${RAUC_TEGRA_DATAIMG_FSOPTS} \
        "$img"

    chmod 0644 "$img"
    mv "$img" "$out"

    if [ -n "${RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME}" ]; then
        ln -sf "${IMAGE_NAME}.dataimg" "${IMGDEPLOYDIR}/${RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME}"
    fi
}

# Keep /data out of the A/B rootfs images. This OE-Core (scarthgap) has no
# IMAGE_ROOTFS_EXCLUDE_PATH, so the content of the mount point is moved to a
# staging directory at the end of do_rootfs instead; the (empty) mount point
# itself stays. The staging directory is kept so that do_image_dataimg can be
# re-run without do_rootfs. It runs under the recipe's pseudo, which preserves
# ownership and permissions.
rauc_tegra_stage_data() {
    rm -rf "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
    mkdir -p "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
    if [ -d "${IMAGE_ROOTFS}${DATA_MOUNT_POINT}" ]; then
        cp -a "${IMAGE_ROOTFS}${DATA_MOUNT_POINT}/." "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}/"
        find "${IMAGE_ROOTFS}${DATA_MOUNT_POINT}" -mindepth 1 -delete
    fi
}
ROOTFS_POSTPROCESS_COMMAND += "rauc_tegra_stage_data;"

do_image_dataimg[depends] += "e2fsprogs-native:do_populate_sysroot"

DATAFILE ?= "${IMAGE_BASENAME}-${MACHINE}.dataimg"
IMAGE_TEGRAFLASH_DATA ?= "${IMGDEPLOYDIR}/${RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME}"
