FILESEXTRAPATHS:append := ":${THISDIR}/${BPN}"

CURTHISDIR := "${THISDIR}"

FLASH_XML_FILE:jetson-tx2-devkit = "flash_l4t_t186.xml"
FLASH_XML_FILE:jetson-nano-devkit-emmc = "flash_jetson_nano_devkit_emmc.xml"

SRC_URI = "file://${FLASH_XML_FILE}"

# This file has been taken from the upstream binary distribution and
# modified to include the required partition layout changes for RAUC slots.
PARTITION_FILE = "${CURTHISDIR}/${BPN}/${FLASH_XML_FILE}"
