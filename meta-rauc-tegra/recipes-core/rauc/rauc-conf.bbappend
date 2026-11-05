# --- Common to all machines -------------------------------------------------

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install:append() {
    sed -i -e 's|@MACHINE@|${MACHINE}|' ${D}${sysconfdir}/rauc/system.conf
}

# --- Jetson TX2 -------------------------------------------------------------

FILESEXTRAPATHS:prepend:tegra186 := "${THISDIR}/files:"

RDEPENDS:${PN}:append:tegra186 = " \
    u-boot-fw-utils \
    u-boot-tegra-env \
"

# --- Jetson Orin Nano devkits -----------------------------------------------

FILESEXTRAPATHS:prepend:jetson-orin-nano-devkit := "${THISDIR}/files:${THISDIR}/files/jetson-orin-nano-devkit:"

SRC_URI:append:jetson-orin-nano-devkit = " \
    file://rauc-nvbootctrl-backend \
    file://data-directory.conf \
"

# Must match the DATA partition mount point (see base-files_%.bbappend).
DATA_MOUNT_POINT ?= "/data"

# nvbootctrl is used by the custom bootloader backend. tegra-redundant-boot also ships nv_update_verifier.service, which runs 'nvbootctrl verify' on every boot; without it the bootloader retry counters are never cleared and slots fail over / become unbootable. efivar is used to reset the rootfs status of a slot that was flagged unbootable.
RDEPENDS:${PN}:append:jetson-orin-nano-devkit = " \
    tegra-redundant-boot-base \
    tegra-redundant-boot \
    efivar \
"

do_install:append:jetson-orin-nano-devkit() {
    sed -i -e 's|@DATA_MOUNT_POINT@|${DATA_MOUNT_POINT}|g' ${D}${sysconfdir}/rauc/system.conf
    install -d ${D}${systemd_system_unitdir}/rauc.service.d
    install -m 0644 ${WORKDIR}/data-directory.conf ${D}${systemd_system_unitdir}/rauc.service.d/data-directory.conf
    sed -i -e 's|@DATA_MOUNT_POINT@|${DATA_MOUNT_POINT}|g' ${D}${systemd_system_unitdir}/rauc.service.d/data-directory.conf
    install -d ${D}${libexecdir}
    install -m 0755 ${WORKDIR}/rauc-nvbootctrl-backend ${D}${libexecdir}/rauc-nvbootctrl-backend
}

FILES:${PN}:append:jetson-orin-nano-devkit = " \
    ${libexecdir}/rauc-nvbootctrl-backend \
    ${systemd_system_unitdir}/rauc.service.d/data-directory.conf \
"
