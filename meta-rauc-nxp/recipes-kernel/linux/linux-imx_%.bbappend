FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://rauc.cfg"

# linux-imx from meta-imx/meta-imx-bsp does not inherit linux-yocto and does not implement the fragment mechanisms.
# So we just add it and call merge-config manually, should one choose to use the iMX downstream recipe (rather than the community fsl one)
do_configure:append() {
	# ${S}: source ;  ${B}: build ; ${WORKDIR}: workdir (fragments go there via SRC_URI)
	if [ -f "${WORKDIR}/rauc.cfg" ]; then
		# We use the kernel's own script to ensure it's done right
		${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/rauc.cfg

		# This part ensures the .config is valid and dependencies are resolved
		oe_runmake -C ${S} O=${B} oldconfig
	fi
}
