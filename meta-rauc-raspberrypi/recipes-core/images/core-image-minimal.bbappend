# Store the kernel in the rootfs partition
IMAGE_INSTALL:append = " kernel-image kernel-modules"

# Remove the kernel from the /boot partition because it is in rootfs
RPI_EXTRA_IMAGE_BOOT_FILES:remove = "${KERNEL_IMAGETYPE}"
