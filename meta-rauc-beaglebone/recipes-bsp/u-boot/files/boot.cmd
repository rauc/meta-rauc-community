run findfdt;

test -n "${BOOT_ORDER}" || env set BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || env set BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || env set BOOT_B_LEFT 3

env set bootpart
env set bootdev
env set raucslot

for BOOT_SLOT in "${BOOT_ORDER}"; do
    if test "x${bootpart}" != "x"; then
        # stop checking after selecting a slot

    elif test "x${BOOT_SLOT}" = "xA"; then
        if itest ${BOOT_A_LEFT} -gt 0; then
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Booting RAUC slot A"

            setenv bootpart "/dev/mmcblk0p2"
            setenv raucslot "A"
            setenv bootdev "mmc 0:2"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if itest ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv bootpart "/dev/mmcblk0p3"
            setenv raucslot "B"
            setenv bootdev "mmc 0:3"
        fi
    fi
done


if test -n "${bootpart}"; then
    setenv bootargs "console=${console} ${optargs} root=${bootpart} rw rootfstype=ext4 rootwait fixrtc rauc.slot=${raucslot}"
    saveenv
else
    echo "No valid RAUC slot found. Resetting attempts to 3"
    setenv BOOT_A_LEFT 3
    setenv BOOT_B_LEFT 3
    saveenv
    reset
fi


if mmc dev 0; then
    
    if test ! -e mmc 0:1 ${bootdir}/uboot.env; then saveenv; fi;

    part uuid ${bootdev} uuid
    load mmc 0:1 ${loadaddr} ${bootdir}/zImage
    load mmc 0:1 ${fdtaddr} ${bootdir}/${fdtfile}
    bootz ${loadaddr} - ${fdtaddr}
else
    echo "Could not find mmc 0"
    reset
fi
