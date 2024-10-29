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

            setenv bootpartition "1"
            setenv bootpart "/dev/mmcblk0p1"
            setenv raucslot "A"
            setenv bootdev "mmc 0:1"
        fi

    elif test "x${BOOT_SLOT}" = "xB"; then
        if itest ${BOOT_B_LEFT} -gt 0; then
            setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
            echo "Booting RAUC slot B"

            setenv bootpartition "2"
            setenv bootpart "/dev/mmcblk0p2"
            setenv raucslot "B"
            setenv bootdev "mmc 0:2"
        fi
    fi
done

setenv bootfile boot/fitImage
setenv rootpartition ${bootpartition}

# Handle legacy split boot and root partition layout
if test ! -e ${devtype} ${devnum}:${bootpartition} ${bootfile}; then
	setenv bootfile fitImage
	setexpr rootpartition ${bootpartition} + 1
fi

if test ! -e ${devtype} ${devnum}:${bootpartition} ${bootfile}; then
  echo "This boot medium does not contain a suitable fitImage file for this system."
  echo "devtype=${devtype} devnum=${devnum} partition=${bootpartition} loadaddr=${loadaddr}"
  echo "Aborting boot process."
  exit 1
fi

# Some STM32MP1-based systems do not encode the baudrate in the console variable
if test "${console}" = "ttySTM0" && test -n "${baudrate}"; then
  setenv console "${console},${baudrate}"
fi

if test -n "${bootpart}"; then
    if test -n "${console}"; then
        setenv bootargs "root=${bootpart} rw rootwait consoleblank=0 console=${console} quiet loglevel=0 rauc.slot=${raucslot}"
    else
        setenv bootargs "root=${bootpart} rw rootwait consoleblank=0 quiet loglevel=0 rauc.slot=${raucslot}"
    fi
    saveenv
else
    echo "No valid RAUC slot found. Resetting attempts to 3"
    setenv BOOT_A_LEFT 3
    setenv BOOT_B_LEFT 3
    saveenv
    reset
fi

load ${devtype} ${devnum}:${bootpartition} ${loadaddr} ${bootfile}
if test $? != 0 ; then
  echo "Failed to load fitImage file for this system from boot medium."
  echo "devtype=${devtype} devnum=${devnum} partition=${bootpartition} loadaddr=${loadaddr}"
  echo "Aborting boot process."
  exit 2
fi

# Assure that initrd relocation to the end of DRAM will not interfere
# with application of relocated DT and DTOs at %UBOOT_DTB_LOADADDRESS% , clamp the
# initrd relocation address below UBOOT_DTB_LOADADDRESS = %UBOOT_DTB_LOADADDRESS%.
if test -z "${initrd_high}" ; then
  setenv initrd_high %UBOOT_DTB_LOADADDRESS%
fi

# Check whether PLL4P supplies 100 MHz to MCO2, MCO2 divides these 100 MHz
# by 2 and supplies DHCOM LAN8710Ai PHY. This is so since U-Boot 2021.04
# 69ea30e688c4 ("ARM: dts: stm32: Switch to MCO2 for PHY 50 MHz clock")
# but older U-Boot versions still set PLL4P to 50 MHz and supply the PHY
# directly from PLL4P. This OE layer contains a backport of Linux commit
# 73ab99aad50c ("ARM: dts: stm32: Switch DWMAC RMII clock to MCO2 on DHCOM")
# which requires PLL4P to supply MCO2 as described above, otherwise the PHY
# would fail to work in Linux. In case of old U-Boot version, fix up the
# PLL4P and MCO2 settings here and urge users to update.

setexpr somname sub ".*stm32mp15.*dhcom.*" "match" "${board_name}"
if test "${somname}" = "match" ; then
	setexpr pll4cfgr2divp *0x5000089c \& 0x3f
	if test "${pll4cfgr2divp}" = "b" ; then
		echo "WARNING"
		echo "Old PLL4P / MCO2 setting detected, please update bootloader"
		echo "to U-Boot 2021.04 or newer. Applying fixup. Refer to commits:"
		echo "  U-Boot: 69ea30e688c4 (ARM: dts: stm32: Switch to MCO2 for PHY 50 MHz clock)"
		echo "  Linux:  73ab99aad50c (ARM: dts: stm32: Switch DWMAC RMII clock to MCO2 on DHCOM)"
		# Set RCC PLL4 DIVP=6, DIVQ=12, DIVR=12
		mw 0x5000089c 0xb0b05
		# Set RCC MCO2 source to PLL4P, divided by 2
		mw 0x50000804 0x1013
	fi
fi

# A custom script exists to load DTOs
if test -n "${loaddtoscustom}" ; then
  if test -z "${loaddtos}" ; then
    echo "Using base DT from fitImage default configuration as fallback."
    fdt addr ${loadaddr}
    fdt get value loaddtos /configurations default
    setenv loaddtos "#${loaddtos}"
    echo "To select different base DT to be adjusted using 'loaddtoscustom'"
    echo "script and passed to Linux kernel, set 'loaddtos' variable:"
    echo "  => env set loaddtos \#conf@...dtb"
  fi

  # Matches UBOOT_DTB_LOADADDRESS in OE layer machine config
  setenv loadaddrdtb %UBOOT_DTB_LOADADDRESS%
  # Matches UBOOT_DTBO_LOADADDRESS in OE layer machine config
  setenv loadaddrdtbo %UBOOT_DTBO_LOADADDRESS%

  setexpr loaddtossep gsub '#conf' ' fdt' "${loaddtos}"
  setexpr loaddtb 1

  for i in ${loaddtossep} ; do
    if test ${loaddtb} = 1 ; then
      echo "Using base DT ${i}"
      imxtract ${loadaddr} ${i} ${loadaddrdtb} ;
      fdt addr ${loadaddrdtb}
      fdt resize 0x40000
      setenv loaddtb 0
    else
      echo "Applying DTO ${i}"
      imxtract ${loadaddr} ${i} ${loadaddrdtbo} ;
      fdt apply ${loadaddrdtbo}
    fi
  done

  setenv loaddtb
  setenv loaddtossep
  setenv loadaddrdtbo
  setenv loadaddrdtb

  # Run the custom DTO loader script
  #
  # In case 'loaddtos' variable is set, then the 'fdt' command is already
  # configured to point to a DT, on top of which all the DTOs present in
  # the fitImage and selected by the 'loaddtos' are applied. Hence, the
  # user is now free to apply any additional custom DTOs loaded from any
  # other source.
  #
  # In case 'loaddtos' variable is not set, the 'loaddtoscustom' script
  # must configure the 'fdt' command to point to the custom DT.
  run loaddtoscustom
  if test -z "${bootm_args}" ; then
    setenv bootm_args "${loadaddr} - ${fdtaddr}"
  fi
else
  setenv bootm_args "${loadaddr}${loaddtos}"
fi

echo "Booting the Linux kernel..." \
&& bootm ${bootm_args}
