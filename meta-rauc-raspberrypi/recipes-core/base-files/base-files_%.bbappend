FILESEXTRAPATHS:prepend:rpi := "${THISDIR}/files:"

# Add a mount point for a shared data partition
dirs755 += "/data"
