# Jetson Orin Nano devkits (jetson-orin-nano-devkit and jetson-orin-nano-devkit-nvme) only: the do_install edits below are applied through the jetson-orin-nano-devkit machine override.
#
# Select the flash layout holding the rootfs device.
#
# - NVMe machines (jetson-orin-nano-devkit-nvme) boot from a device other than the machine's default one (TNSPEC_BOOTDEV != TNSPEC_BOOTDEV_DEFAULT, the same test as TEGRAFLASH_ROOTFS_EXTERNAL in image_types_tegra.bbclass): the rootfs device is described by external-flash.xml.
# - SD card machines (jetson-orin-nano-devkit) boot from the default device: the SD card is the <device type="sdcard"> block of internal-flash.xml, next to the QSPI (<device type="spi">) block. Edits are then limited to that block, as the QSPI block has its own secondary_gpt partition. An external-flash.xml is still generated for these machines (tegra234.inc sets PARTITION_LAYOUT_EXTERNAL), but it is not used for flashing, so it must be left alone.
#
# Sets 'layout' (file to edit) and 'device' (device type to restrict the edits to, empty for the whole file). Leaves 'layout' empty when no rootfs device layout is found, in which case callers do nothing.

JETSON_RAUC_ROOTFS_EXTERNAL = "${@'1' if d.getVar('TNSPEC_BOOTDEV') != d.getVar('TNSPEC_BOOTDEV_DEFAULT') else '0'}"

jetson_rauc_select_layout() {
    layout="${D}${datadir}/tegraflash/external-flash.xml"
    device=""
    if [ "${JETSON_RAUC_ROOTFS_EXTERNAL}" = "1" ]; then
        if [ ! -e "$layout" ]; then
            layout=""
        fi
        return 0
    fi
    layout="${D}${datadir}/tegraflash/internal-flash.xml"
    device="sdcard"
    if [ ! -e "$layout" ] || ! grep -Eq '^[[:space:]]*<device type="sdcard"' "$layout"; then
        layout=""
    fi
}

# Remove the stock kernel partitions from the rootfs device flash layout (the external NVMe layout, or the SD card block of the internal layout).
#
# The A/B design of this integration keeps kernel, initrd, DTB and modules in each rootfs slot (/boot, loaded by L4TLauncher through extlinux.conf), so a RAUC update replaces them together with the rootfs. The stock A_kernel / B_kernel partitions (and their -dtb and reserved companions) hold a second, flash-time-only copy that RAUC never updates: it would be a stale kernel that L4TLauncher silently falls back to when extlinux.conf is missing, hiding a broken slot instead of failing early. The recovery, esp and other partitions are kept.
#
# Partition ids without an explicit id continue from the previous partition's id, starting at 1. APP/APP_b carry the fixed ids 1 and 2 (the stock layout started the numbering at 3 through A_kernel's explicit id), so the first remaining partition (recovery) must get an explicit id of 3, otherwise it collides with APP and the GPT cannot be created. The partitions after it are renumbered; everything in the image refers to them by label. At do_install time the recovery partition is still named by the placeholder RECNAME (substituted later when the flash package is assembled).

REMOVE_KERNEL_PARTITIONS ?= "1"
KERNEL_PARTITIONS_TO_REMOVE ?= "A_kernel A_kernel-dtb A_reserved_on_user B_kernel B_kernel-dtb B_reserved_on_user"
KERNEL_PARTITIONS_FIRST_PART ?= "RECNAME"
KERNEL_PARTITIONS_FIRST_ID ?= "3"

do_install:append:jetson-orin-nano-devkit() {
    jetson_rauc_select_layout
    if [ "${REMOVE_KERNEL_PARTITIONS}" != "1" ] || [ -z "$layout" ]; then
        return 0
    fi
    # Drop each listed <partition name="..."> ... </partition> block.
    # The first remaining partition gets an explicit id (see above).
    awk -v names="${KERNEL_PARTITIONS_TO_REMOVE}" -v dev="$device" \
        -v first="${KERNEL_PARTITIONS_FIRST_PART}" -v firstid="${KERNEL_PARTITIONS_FIRST_ID}" '
        BEGIN { n = split(names, list, " "); for (i = 1; i <= n; i++) drop[list[i]] = 1; in_dev = (dev == "") }
        /<device / { in_dev = (dev == "" || index($0, "type=\"" dev "\"") > 0) }
        skip { if ($0 ~ /<\/partition>/) skip = 0; next }
        in_dev && /<partition name="/ {
            name = $0
            sub(/.*<partition name="/, "", name)
            sub(/".*/, "", name)
            if (name in drop) { skip = 1; next }
            if (name == first && $0 !~ / id="/) {
                sub("<partition name=\"" first "\"", "<partition name=\"" first "\" id=\"" firstid "\"")
            }
        }
        { print }
    ' "$layout" > "$layout.new"
    mv "$layout.new" "$layout"
    for name in ${KERNEL_PARTITIONS_TO_REMOVE}; do
        if grep -q "<partition name=\"$name\"" "$layout"; then
            bbfatal "Failed to remove partition $name from $layout"
        fi
    done
    if ! grep -q "<partition name=\"${KERNEL_PARTITIONS_FIRST_PART}\" id=\"${KERNEL_PARTITIONS_FIRST_ID}\"" "$layout"; then
        bbfatal "Partition ${KERNEL_PARTITIONS_FIRST_PART} has no explicit id ${KERNEL_PARTITIONS_FIRST_ID} in $layout"
    fi
}

# Append a persistent data partition to the rootfs device flash layout (the external NVMe layout, or the SD card block of the internal layout).
#
# The partition is placed after APP_b and is flagged "fill to end" (allocation_attribute bit 0x800), so make-sdcard/initrd-flash creates it with 'sgdisk --largest-new' and it takes all space left on the device, whatever its size. It is mounted on /data (see base-files_%.bbappend) and not touched by RAUC updates.
#
# Two modes, selected by RAUC_TEGRA_DATAIMG_SIZE_MB (a global setting, also used by classes/rauc-dataimg-tegra.bbclass):
# - empty (default): the partition is formatted at flash time (filesystem_type) and starts empty.
# - set (MiB): the partition is flashed from the data image built by the class, through a <filename> DATAFILE </filename> entry (replaced by meta-tegra at packaging/flash time). The image must be built, i.e. the class must be inherited by the flashed image: the SD card flow keeps the literal placeholder when it has no data image. The image is smaller than the fill-to-end partition, so the filesystem is grown at first mount (see base-files_%.bbappend). filesystem_type is 'basic' in this mode, as for APP: make-sdcard only creates a filesystem for partitions without a file.
#
# The partition id has to be set explicitly: the ids of the layout are consumed up to 16 (reserved), and APP/APP_b carry the fixed ids 1 and 2.

DATA_PART_ENABLE ?= "1"
DATA_PART_NAME ?= "DATA"
DATA_PART_ID ?= "${@'11' if d.getVar('REMOVE_KERNEL_PARTITIONS') == '1' else '17'}"
RAUC_TEGRA_DATAIMG_SIZE_MB ?= ""
DATA_PART_FSTYPE ?= "${@'basic' if d.getVar('RAUC_TEGRA_DATAIMG_SIZE_MB') else 'ext4'}"
DATA_PART_SIZE_BYTES ?= "${@int(d.getVar('RAUC_TEGRA_DATAIMG_SIZE_MB')) * 1048576 if d.getVar('RAUC_TEGRA_DATAIMG_SIZE_MB') else 134217728}"
DATA_PART_FILENAME_XML ?= "${@'<filename> DATAFILE </filename>' if d.getVar('RAUC_TEGRA_DATAIMG_SIZE_MB') else ''}"

do_install:append:jetson-orin-nano-devkit() {
    jetson_rauc_select_layout
    if [ "${DATA_PART_ENABLE}" != "1" ] || [ -z "$layout" ]; then
        return 0
    fi
    if ! grep -q '<partition name="secondary_gpt"' "$layout"; then
        bbfatal "No secondary_gpt partition found in $layout, cannot add ${DATA_PART_NAME}"
    fi
    if grep -q '<partition name="${DATA_PART_NAME}"' "$layout"; then
        bbfatal "Partition ${DATA_PART_NAME} already exists in $layout"
    fi
    cat > ${WORKDIR}/data-partition.xml <<EOF
        <partition name="${DATA_PART_NAME}" id="${DATA_PART_ID}" type="data">
            <allocation_policy> sequential </allocation_policy>
            <filesystem_type> ${DATA_PART_FSTYPE} </filesystem_type>
            <size> ${DATA_PART_SIZE_BYTES} </size> <!-- nominal, the partition fills the rest of the device -->
            <file_system_attribute> 0 </file_system_attribute>
            <allocation_attribute> 0x808 </allocation_attribute>
            <percent_reserved> 0 </percent_reserved>
            <align_boundary> 16384 </align_boundary>
            ${DATA_PART_FILENAME_XML}
            <description> Persistent data, not part of the A/B update. Fills the remaining space. </description>
        </partition>
EOF
    awk -v snippet_file="${WORKDIR}/data-partition.xml" -v dev="$device" '
        BEGIN { in_dev = (dev == "") }
        /<device / { in_dev = (dev == "" || index($0, "type=\"" dev "\"") > 0) }
        in_dev && /<partition name="secondary_gpt"/ {
            while ((getline line < snippet_file) > 0) print line
        }
        { print }
    ' "$layout" > "$layout.new"
    mv "$layout.new" "$layout"
    if ! grep -q "<partition name=\"${DATA_PART_NAME}\"" "$layout"; then
        bbfatal "Failed to add partition ${DATA_PART_NAME} to $layout"
    fi
}
