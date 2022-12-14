run findfdt;

test -n "${BOOT_ORDER}" || env set BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || env set BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || env set BOOT_B_LEFT 3

env set boot_part
env set boot_dev
env set rauc_slot


for BOOT_SLOT in "${BOOT_ORDER}"; do
    if test "x${boot_part}" != "x"; then
        # stop checking after selecting a slot

    elif test "x${BOOT_SLOT}" = "xA"; then
        if test ${BOOT_A_LEFT} -gt 0; then
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Booting RAUC slot A"

            setenv boot_part 2
            setenv rauc_slot "A"
            setenv boot_dev "mmc 1:2"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if test ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv boot_part 3
            setenv rauc_slot "B"
            setenv boot_dev "mmc 1:3"
        fi
    fi
done


if test -n "${boot_part}"; then
    saveenv
else
    echo "No valid RAUC slot found. Resetting attempts to 3"
    setenv BOOT_A_LEFT 3
    setenv BOOT_B_LEFT 3
    saveenv
    reset
fi


if mmc dev 1; then
    setenv distro_bootpart ${boot_part}
    part uuid ${boot_dev} uuid
    env set devtype mmc
    env set devnum 1
    run scan_dev_for_boot
else
    echo "Could not find mmc 1"
    reset
fi

