DESCRIPTION = "Create sd.img to emulate hard partition"

FILESEXTRAPATHS_append := "${THISDIR}/files:"


inherit deploy


LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI += "file://sdcard_img.sh"
SRC_URI += "file://launch-qemu.sh"


S = "${WORKDIR}/${PN}"
ALLOW_EMPTY_${PN} = "1"

do_create_sdimg[depends] += "core-image-minimal:do_image_wic"



do_create_sdimg() {
	bbplain "**************************************************************"
	bbplain "*                    Create SD-CARD images                    *"
	bbplain "---------------------------------------------------------------"
	#bbplain "CURRENT DIR: $PWD"
	#bbplain "CURRENT S PATH : ${S}"
	#bbplain "CONTAINS : OF $PWD"
	#bbplain "$(ls -al $PWD)"

	#wait little bit before core-image-minimal-qemuarma9.wic was created
	sleep 20

	if [ -f "${DEPLOY_DIR}/images/${MACHINE}/core-image-minimal-${MACHINE}.wic" ];then
		cd ${WORKDIR}

		#delete sd.img if exist
		if [ -f "${DEPLOY_DIR}/images/${MACHINE}/sd.img" ];then
			bbplain "[ INFO ] : delete  ${DEPLOY_DIR}/images/${MACHINE}/sd.img"
			rm -f ${DEPLOY_DIR}/images/${MACHINE}/sd.img
		fi

		
		result="$(./sdcard_img.sh "${DEPLOY_DIR}/images/${MACHINE}")"
		bbplain "[ INFO ] : RESULT :\n${result}"
	else
		bbplain "WIC FILES WAS NOT YET BUILDED"
		#bbplain "CONTAINS: ${DEPLOY_DIR}/images/${MACHINE} "
		#bbplain "$(ls -al ${DEPLOY_DIR}/images/${MACHINE})"
	fi

	if [ -f ${DEPLOY_DIR}/images/${MACHINE}/qemu-run.sh ];then
		bbplain "FILE : ${DEPLOY_DIR}/images/${MACHINE}/qemu-run.sh exist "
		rm -f ${DEPLOY_DIR}/images/${MACHINE}/qemu-run.sh
	fi

	#create copy script to deploydir
	if [ ! -f ${DEPLOY_DIR}/images/${MACHINE}/launch-qemu.sh ];then 
		bbplain "[ INFO ] : Copy script launch-qemu.sh to ${DEPLOY_DIR}/images/${MACHINE}/"
		cp launch-qemu.sh ${DEPLOY_DIR}/images/${MACHINE}/
	else
		bbplain "[ INFO ] : script ${DEPLOY_DIR}/images/${MACHINE}/launch-qemu.sh is available "
	fi
	
}

do_clean() {
	bbplain "**************************************************************"
	bbplain "*                    Delete SD-CARD images                    *"
	bbplain "---------------------------------------------------------------"
	rm -f "${DEPLOY_DIR}/images/${MACHINE}/sd.img"
	rm -f "${DEPLOY_DIR}/images/${MACHINE}/qemu-run.sh"
}

addtask create_sdimg after do_deploy before do_build
do_create_sdimg[nostamp] = "1"
