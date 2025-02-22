# Generate boot.scr.uimg:
# ./tools/mkimage -C none -A arm -T script -d boot.scr.cmd boot.scr.uimg
#
#########################################################################
# SAMPLE BOOT SCRIPT: PLEASE DON'T USE this SCRIPT in REAL PRODUCT
#########################################################################
# this script is only a OpenSTLinux helper to manage multiple target with the
# same bootfs, for real product with only one supported configuration change the
# bootcmd in U-boot or use the normal path for extlinux.conf to use DISTRO
# boocmd (generic distibution); U-Boot searches with boot_prefixes="/ /boot/":
# - /extlinux/extlinux.conf
# - /boot/extlinux/extlinux.conf
#########################################################################

test -n "${BOOT_ORDER}" || env set BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || env set BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || env set BOOT_B_LEFT 3

env set bootpart
env set raucslot

for BOOT_SLOT in "${BOOT_ORDER}"; do
    if test "x${bootpart}" != "x"; then
        # stop checking after selecting a slot

    elif test "x${BOOT_SLOT}" = "xA"; then
        if itest ${BOOT_A_LEFT} -gt 0; then
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Booting RAUC slot A"

            setenv bootpart "rootfs_A"
            setenv raucslot "A"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if itest ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv bootpart "rootfs_B"
            setenv raucslot "B"
        fi
    fi
done

if test -n "${bootpart}"; then
    saveenv
else
    echo "No valid RAUC slot found. Resetting attempts to 3"
    setenv BOOT_A_LEFT 3
    setenv BOOT_B_LEFT 3
    saveenv
    reset
fi
