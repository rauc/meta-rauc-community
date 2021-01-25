FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Add a mount point for a shared data partition
dirs755 += "/data"
dirs755 += "/grubenv"
