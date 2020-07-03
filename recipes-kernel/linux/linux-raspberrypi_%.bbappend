do_configure_append() {
	kernel_configure_variable SQUASHFS y
	kernel_configure_variable BLK_DEV_LOOP y
	kernel_configure_variable SQUASHFS_FILE_CACHE y
        kernel_configure_variable SQUASHFS_DECOMP_SINGLE y
	kernel_configure_variable SQUASHFS_ZLIB y
	kernel_configure_variable SQUASHFS_FRAGMENT_CACHE_SIZE 3
}
