This README file has specific instructions for the NXP FRDM-IMX93 development board.
It is separated from the other README, to allow for more specific instructions, and overrides, that can be useful for demonstrating additional RAUC constructs.
The author has separated the effort to avoid touching the previous authors architecture, and he would be glad to rearchitect the layer.

The file only specifies things that are not already specified in the README.rst file, and keeps the section numbers identical to those in that file,
making the gaps here intentional.
We use the exact same instructions and style. Obviously, you would better add what you need in your respective distro file, and not in local.conf.

The main construct added in this example is a dual (A/B) boot/rootfs partition update scheme, where the disk layout is as follows:

* p1 - BOOT_A
* p2 - BOOT_B
* p3 - RES (e.g., for rescue or recovery image)
* p5 - ROOTFS_A
* p6 - ROOTFS_B
* p7 - DATA

This of course means another kickstart file needs to be implemented, but it also means, that another image class, for getting the required boot files (i.e. what U-Boot expects
to be on a vfat partition) needs to be implemented, so we can populate it and add it to the ``IMAGE_FSTYPES``.

We will introduce a new ``DISTRO_FEATURE``, with the amazing (sorry not sorry) name ``rauc-ab-bootrootfs`` and add all of the above only if it exists, by adding it to the overrides.
This way, the existing recipe code will remain untouched (I would separate it, but I can't test it, and I just wanted to give this example).

**Note** The implementation could be more elegant if we just used another layer or did not bother about the one boot/2rootfs scheme that is in the overall meta-rauc-community repo.
However, to keep things simple for comparison, I made the extra effort to have the previous behavior (one boot, 2 rootfs partitions) the default one.
In the dual boot/rootfs solution (i.e. the ``rauc-ab-bootrootfs`` override), everything is identical except for the partition scheme with the following exceptions:
* No autogrowing the data partition - and renaming the relevant recipe to a common include. Otherwise more work needs to be done
* Less hardcoding otherwise
* U-Boot is fully aware of which device it is running from, and not hardcoded to the sdcard.
    * This can and should be done for the rest of the components - but to keep it very similar to the previous version prior to introducing this feature, the sdcard is assumed.
      This is the first thing I would change if I have time, and it may happen soon enough (hopefully soon enough so you don't even see this line)


II. Build NXP Demo System
===============================================

For FRDM-IMX93 set in local.conf::

    MACHINE = "imx93frdm"
    INIT_MANAGER = "systemd"
    ACCEPT_FSL_EULA = "1"

    #----------------------------------------------
    # RAUC example. It is strongly recommended to
    # not put these things in your local.conf
    # (it is however good for explanations)
    #----------------------------------------------
    # Add RAUC support
    DISTRO_FEATURES:append = " rauc"
    IMAGE_FSTYPES:append = " ext4"
    IMAGE_BOOT_FILES:append = " boot.scr"
    WKS_FILE:imx93frdm = "dual-imx-boot-bootpart.wks.in"

    # Allow selection of the bundle rather than hardcoding it
    BUNDLE_IMAGE_NAME ?= "core-image-base"

    # Add RAUC support for a dual boot, dual rootfs partition scheme
    # First let's add a little cheatcode: make up a little machine override, so that we son't need to use bb.utils.contains more than this time
    MACHINEOVERRIDES:append:imx93frdm = "${@bb.utils.contains('DISTRO_FEATURES', 'rauc-ab-bootrootfs', ':rauc-ab-bootrootfs', '', d)}"
    DISTRO_FEATURES:append = " rauc-ab-bootrootfs"
    BOOT_PARTITION_SIZE_MIB:rauc-ab-bootrootfs = "64"
    RES_PARTITION_SIZE_MIB:rauc-ab-bootrootfs = "10"
    DATA_PARTITION_SIZE_MIB:rauc-ab-bootrootfs = "100"
    IMAGE_CLASSES:append:rauc-ab-bootrootfs = " boot-vfat-image"
    IMAGE_FSTYPES:append:rauc-ab-bootrootfs = " boot.vfat"
    WKS_FILE:rauc-ab-bootrootfs = "imx-2boot-res-2rootfs-data.wks.in"

Build your bundle. It will also build your your respective wic image::

    $ bitbake update-bundle


