test -n "${BOOT_ORDER}" || env set BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || env set BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || env set BOOT_B_LEFT 3

env set boot_pno
env set rootfs_pno;
env set rauc_slot

echo "[+] Booting from mmc device: $mmcdev"

for BOOT_SLOT in "${BOOT_ORDER}"; do
    if test "x${rootfs_pno}" != "x"; then
        # stop checking after selecting a slot

    elif test "x${BOOT_SLOT}" = "xA"; then
        if itest ${BOOT_A_LEFT} -gt 0; then
            setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
            echo "Booting RAUC slot A"

            setenv rootfs_pno 5
            setenv boot_pno 1
            setenv rauc_slot "A"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if itest ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv rootfs_pno 6
            setenv boot_pno 2
            setenv rauc_slot "B"
        fi
    fi
done


if test -n "${rootfs_pno}"; then
    setenv mmcpart $boot_pno;
    saveenv
else
    echo "No valid RAUC slot found. Resetting attempts to 3"
    setenv BOOT_A_LEFT 3
    setenv BOOT_B_LEFT 3
    saveenv
    reset
fi

if itest $mmcdev -eq 1 ; then
    echo "[+] Will now boot RAUC slot $rauc_slot from sdcard"
elif itest $mmcdev -eq 0 ; then 
    echo "[+] Will now boot RAUC slot $rauc_slot from eMMC"
else
    echo "***ERROR: Will ignore mmc device $mmcdev"
    reset
fi

if mmc dev $mmcdev; then
    run sr_ir_v2_cmd
    mmc dev $mmcdev
    setenv devtype mmc
    setenv devnum $mmcdev
    setenv distro_bootpart $boot_pno
    run scan_dev_for_efi
    setenv mmcroot /dev/mmcblk${mmcdev}p${rootfs_pno} rootwait rw rauc.slot=${rauc_slot} rauc_example_mode=rauc-ab-bootrootfs
    if fatload mmc ${mmcdev}:${mmcpart} ${fdt_addr_r} ${fdtfile} ; then
        if fatload mmc ${mmcdev}:${mmcpart} ${loadaddr} ${image} ; then
            setenv bootargs ${jh_clk} ${mcore_clk} console=${console} root=${mmcroot}
            booti ${loadaddr} - ${fdt_addr_r}
	else
	    echo "***ERROR: Failed to boot the Linux kernel"
	fi
    else
	echo "***ERROR: Failed to load the device tree blob $fdtfile"
    fi
else
    echo "***Could not find mmc device $mmcdev"
    reset
fi

