# ---
# Extend the default partition table with the shared data partition.

# Add a mount points
dirs755 += "/data"


do_install:append() {
    printf "/dev/vda4    /data      auto    defaults,sync   0  0\n\n" >> ${D}/${sysconfdir}/fstab
}