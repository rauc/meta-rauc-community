require ${@bb.utils.contains('DISTRO_FEATURES', 'rauc', '${BPN}_rauc.inc', '', d)}

FILESEXTRAPATHS:prepend := " ${THISDIR}/files/qemux86:"

SRC_URI:append := " file://system.conf"
