# Jetson Orin Nano devkits: ship the kernel DTB in each rootfs (/boot) and load it through extlinux.conf, so a RAUC update replaces it together with the rootfs. 
# Without it L4TLauncher uses the DTB of the UEFI image in QSPI, which RAUC does not update.
UBOOT_EXTLINUX_FDT:jetson-orin-nano-devkit ?= "${DTBFILE}"

# l4t-extlinux-config reads UBOOT_EXTLINUX_FDT through a function argument (get_l4t_extlinux_compat_var), so bitbake does not see it as a dependency and a changed value is silently satisfied from a stale sstate package.
# 
# Declare the dependency explicitly so the package is rebuilt when the FDT/overlay settings change.
do_create_extlinux_config[vardeps] += "UBOOT_EXTLINUX_FDT UBOOT_EXTLINUX_FDTOVERLAYS"
do_copy_dtb_overlays[vardeps] += "UBOOT_EXTLINUX_FDT UBOOT_EXTLINUX_FDTOVERLAYS"
do_sign_files[vardeps] += "UBOOT_EXTLINUX_FDT UBOOT_EXTLINUX_FDTOVERLAYS"
do_install[vardeps] += "UBOOT_EXTLINUX_FDT UBOOT_EXTLINUX_FDTOVERLAYS"
