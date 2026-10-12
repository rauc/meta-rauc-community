# Generate an ext4 data image for NVIDIA tegraflash packages.
#
# Projects can use this to provision persistent files outside the RAUC-managed
# rootfs slots during factory flashing. Files installed below ${IMAGE_ROOTFS}/data
# are copied into this image, while /data is kept out of the rootfs image.
#
# The project layer must still size the image for the selected flash partition,
# add a DATAFILE filename entry to that partition in the Tegra flash XML, and
# arrange for the flashed partition and its mount point at runtime.

IMAGE_FSTYPES:append = " dataimg"
IMAGE_TYPEDEP:tegraflash:append = " dataimg"

# Size of the ext4 image in MiB. It must fit in the target flash partition.
RAUC_TEGRA_DATAIMG_SIZE_MB ?= ""
RAUC_TEGRA_DATAIMG_LABEL ?= "data"
RAUC_TEGRA_DATAIMG_FSOPTS ?= ""

# Internal staging directory populated from ${IMAGE_ROOTFS}/data before mkfs.ext4.
RAUC_TEGRA_DATAIMG_POPULATE_DIR ?= "${WORKDIR}/dataimg-rootfs"

# Deploy symlink for tools that prefer a stable name such as data.img.
RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME ?= "data.img"

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

# Keep /data out of the A/B rootfs images; dataimg copies it first so factory
# provisioning content is still present in the separate filesystem image.
IMAGE_ROOTFS_EXCLUDE_PATH += "/data"

do_copy_data_rootfs() {
    rm -rf "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
    mkdir -p "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
    if [ -d "${IMAGE_ROOTFS}/data" ]; then
        cp -a "${IMAGE_ROOTFS}/data/." "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}/"
    fi
}

do_delete_data_rootfs() {
    rm -rf "${RAUC_TEGRA_DATAIMG_POPULATE_DIR}"
}

do_image_dataimg[prefuncs] += "do_copy_data_rootfs"
do_image_dataimg[postfuncs] += "do_delete_data_rootfs"

do_image_dataimg[depends] += "e2fsprogs-native:do_populate_sysroot"
do_image_dataimg[respect_exclude_path] = "0"

IMAGE_TYPEDEP:tegraflash-tar += " dataimg"

DATAFILE ?= "${IMAGE_BASENAME}-${MACHINE}.dataimg"
IMAGE_TEGRAFLASH_DATA ?= "${IMGDEPLOYDIR}/${RAUC_TEGRA_DATAIMG_DEPLOY_LINK_NAME}"
