FILESEXTRAPATHS:prepend:dhsom-stm32-rauc := "${THISDIR}/files:"

# Add a mount point for a shared data partition
dirs755 += "/data"
