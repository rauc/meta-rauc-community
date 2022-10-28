DESCRIPTION = "RAUC bundle generator"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit bundle

RAUC_BUNDLE_COMPATIBLE = "qemuarm"
RAUC_BUNDLE_VERSION = "v20200703"
RAUC_BUNDLE_DESCRIPTION = "RAUC Demo Bundle qemuarm"
RAUC_BUNDLE_SLOTS = "rootfs" 
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "ext4"


RAUC_KEY_FILE = "${THISDIR}/files/development-1.key.pem"
RAUC_CERT_FILE = "${THISDIR}/files/development-1.cert.pem"

SRC_URI += " file://hook.sh"
RAUC_BUNDLE_HOOKS[file] = "hook.sh"
#RAUC_BUNDLE_HOOKS[hooks] = "post-install"
RAUC_SLOT_rootfs[hooks] = "post-install"