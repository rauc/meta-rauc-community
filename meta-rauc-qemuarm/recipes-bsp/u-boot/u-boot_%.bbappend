# ---
# qemuarm specific integration of u-boot for usage with RAUC
#
# While there are other ways to make u-boot aware of the multiboot setup (e.g. 
# by compiling env variables into it), this demo uses a bootscript-based approach.
# However, as the bootscript is provided alongside (and not as a part) of the
# u-boot binary, it needs to be deployed in a dedicated FAT partition.
#
# Besides, we adjust the boot sequence (just for convenience, to make things a bit faster).
#
# Regarding persistent bootloader environment: To mimic an application case that is closer
# to real-world scenarios we use the built-in flash (to be exact: pflash1) emulated by Qemu.
# It's parameters can be found at
#   https://github.com/u-boot/u-boot/blob/master/configs/qemu_arm_defconfig
# Note that in order for this to work, the kernel must be configured accordingly (with enabled
# MTD subsystem and physmap driver).

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0001-qemu-arm-prefer-virtio-as-boot-source.patch \
    file://fw_env.config \
    file://boot.cmd.in \
"

# The boot script loads the devicetree from the rootfs, so we need to make sure it's deployed.
RDEPENDS:${PN} = " devicetree-qemuarm"
DEVICETREE_NAME = "${MACHINE}.dtb"

KERNEL_BOOTCMD:qemuarm = "bootz"
KERNEL_BOOTCMD:qemuarm64 = "booti"

# Compile the boot.scr and make it available in the DEPLOYDIR
UBOOT_ENV = "boot"
UBOOT_ENV_SUFFIX = "scr"

# Set the required entrypoint and loadaddress
# These are usually 00008000 for ARM machines
UBOOT_ENTRYPOINT = "0x00008000"
UBOOT_LOADADDRESS = "0x00008000"

# Provide the empty flash image to persist the bootloader environment
UBOOT_BOOTENV_FILE = "bootenv.img"

do_configure:prepend () {
    sed -e 's/@@DEVICETREE_NAME@@/${DEVICETREE_NAME}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        "${UNPACKDIR}/boot.cmd.in" > "${UNPACKDIR}/boot.cmd"
}

do_deploy:append (){
    # Note: The flash size is predefined by qemu
    qemu-img create -f raw ${UBOOT_BOOTENV_FILE} 64M
}

do_deploy[depends] += "qemu-system-native:do_populate_sysroot"