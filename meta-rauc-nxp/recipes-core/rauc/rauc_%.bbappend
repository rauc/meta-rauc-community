FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# For backward compatability, only include the grow-partition logic if 'rauc-ab-bootrootfs' is NOT in OVERRIDES
# The .inc file is identical to the previous contents of this .bbappend file
include ${@bb.utils.contains('OVERRIDES', 'rauc-ab-bootrootfs', '', 'rauc-grow-partition.inc', d)}
