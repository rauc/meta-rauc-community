test -n "${BOOT_ORDER}" || env set BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || env set BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || env set BOOT_B_LEFT 3

env set boot_part
env set rauc_slot

for BOOT_SLOT in "${BOOT_ORDER}"; do
    if test "x${boot_part}" != "x"; then
        # stop checking after selecting a slot

    elif test "x${BOOT_SLOT}" = "xA"; then
        if itest ${BOOT_A_LEFT} -gt 0; then
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Booting RAUC slot A"

            setenv boot_part 2
            setenv rauc_slot "A"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if itest ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv boot_part 3
            setenv rauc_slot "B"
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
    run sr_ir_v2_cmd
    mmc dev 1
    setenv devtype mmc
    setenv devnum 1
    setenv distro_bootpart 1
    run scan_dev_for_efi
    setenv mmcroot /dev/mmcblk1p${boot_part} rootwait rw rauc.slot=${rauc_slot}
    fatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image}
    setenv bootargs ${jh_clk} ${mcore_clk} console=${console} root=${mmcroot}
    booti ${loadaddr} - ${fdt_addr_r}
else
    echo "Could not find mmc 1"
    reset
fi

