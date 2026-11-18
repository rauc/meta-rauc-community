do_image_boot_vfat[depends] += "mtools-native:do_populate_sysroot dosfstools-native:do_populate_sysroot"
do_image_boot_vfat[vardepsexclude] += "DATETIME"

IMAGE_CMD:boot.vfat () {
        # datetime: compute here to avoid non determinism at the recipe level
        local datetime=$(date +%Y%m%d%H%M%S)
        local outfile=${IMGDEPLOYDIR}/${IMAGE_BASENAME}-${MACHINE}-${datetime}.boot.vfat
        local linkfile=${IMGDEPLOYDIR}/${IMAGE_BASENAME}-${MACHINE}.boot.vfat

        # Remove old timestamped files
        rm -f ${IMGDEPLOYDIR}/${IMAGE_BASENAME}-${MACHINE}-*.boot.vfat

        dd if=/dev/zero of=$outfile bs=1M count=64
        mkfs.vfat $outfile

        for entry in ${IMAGE_BOOT_FILES}; do
            src=$(echo $entry | cut -d';' -f1)
            dst=$(echo $entry | cut -d';' -f2)
            dst=${dst:-$src}
            if [ -f ${DEPLOY_DIR_IMAGE}/$src ]; then
                mcopy -i $outfile -s ${DEPLOY_DIR_IMAGE}/$src ::/$dst
            else
                bbwarn "$src does not exist although it is specified in your IMAGE_BOOT_FILES variable"
            fi
        done

        cd ${IMGDEPLOYDIR}
        ln -sf ${IMAGE_BASENAME}-${MACHINE}-${datetime}.boot.vfat $linkfile
}

#
# Testing tip:
# Allow an (optional!) rfile.txt entry at IMGDEPLOYDIR - one can modify it prior to the build, to see a change in a single file, on the boot partition, and it should be super quick
# e.g., cf. modifying a possibly huge rootfs
# Then, for testing one could do something like
# date > tmp/deploy/images/imx93frdm/bootpart.testinfo && bitbake update-bundle
# Then, because it is an intentional "hack" (to build fast / and not change anything if we don't do it explicitly) one would do, to force a rebuild of the wic (unnecessary, but to to sync the states)
# and the filesystem, and therefore the bundle as follows:
#
# bitbake core-image-minimal -C image_boot_vfat
# bitbake core-image-minimal
#
# If you are interested in doing these tests, uncomment the next line, and then you could mount the boot partition upon boot, and see the works when you will have flashed the image or update bundle
#
# IMAGE_BOOT_FILES:append = " bootpart.testinfo"
#
