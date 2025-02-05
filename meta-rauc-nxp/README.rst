This README file contains information on the contents of the meta-rauc-nxp layer.

Please see the corresponding sections below for details.

Dependencies
============

This layer depends on:

* `oe-core <https://git.openembedded.org/openembedded-core>`__
* `meta-rauc <https://github.com/rauc/meta-rauc.git>`__
* `meta-freescale <https://git.yoctoproject.org/meta-freescale>`__
* `meta-freescale-3rdparty <https://github.com/Freescale/meta-freescale-3rdparty.git>`__
* `meta-freescale-distro <https://github.com/Freescale/meta-freescale-distro.git>`__


Patches
=======

Please submit any patches against the meta-rauc-nxp layer via GitHub
pull requests on https://github.com/rauc/meta-rauc-community.

Maintainer: Leon Anavi <leon.anavi@konsulko.com>


Disclaimers
===========

Note that this is just an example layer that shows a possible RAUC
configuration.
Actual requirements may differ from project to project and will
probably need a much different RAUC/bootloader/system configuration.


Currently this layer supports:

* cubox-i/HummingBoard boards
* Olimex iMX8MP-SOM-4GB-IND / iMX8MP-SOM-EVB-IND


I. Adding the meta-rauc-nxp layer to your build
===============================================

Run ``bitbake-layers add-layer meta-rauc-nxp``


II. Build NXP Demo System
===============================================

For Olimex iMX8MP-SOM-4GB-IND and iMX8MP-SOM-EVB-IND set in local.conf::

    MACHINE = "olimex-imx8mp-evb"
    INIT_MANAGER = "systemd"
    ACCEPT_FSL_EULA = "1"
    WKS_FILE = "dual-imx-boot-bootpart.wks.in"
    DISTRO_FEATURES:append = " rauc"
    IMAGE_FSTYPES:append = " ext4"
    IMAGE_BOOT_FILES:append = " boot.scr"

For cubox-i/HummingBoard follow the steps below::

    $ . oe-init-build-env

Set ``MACHINE`` to ``cubox-i`` in your local.conf::

    MACHINE = "cubox-i"

Accept end user agreement for meta-freescale::

    ACCEPT_FSL_EULA = "1"

It is recommended, but not necessary, to enable 'systemd'::

    INIT_MANAGER = "systemd"

Add configuration required for RAUC to your local.conf::

    IMAGE_INSTALL:append = " rauc"
    DISTRO_FEATURES:append = " rauc"
    # ext4 image format required
    IMAGE_FSTYPES:append = " ext4"

Append the u-boot script to boot files::

    IMAGE_BOOT_FILES:append = " boot.scr"

Select the Kickstart file::

    WKS_FILE = "sdimage-dual-cubox-i.wks.in"
    WKS_FILES:prepend = "sdimage-dual-cubox-i.wks.in "

You can increase the size of rootfs to contain software added when updating::

    # Add 150 000 Kbytes free space to rootfs
    IMAGE_ROOTFS_EXTRA_SPACE:append = " + 150000"

Create example authentication keys (from sourced environment)::

    $ ../meta-rauc-community/create-example-keys.sh

Build the minimal system image::

    $ bitbake core-image-minimal


III. Flash & Run the Demo System
================================

Before flashing it's recommended to make sure that any traces
of u-boot environment that may have been left from previous use
of the SD card with the cubox-i/hummingboard board are erased::

    $ dd if=/dev/zero of=/dev/sdX count=10000

You can either flash using bmaptool (recommended)::

    $ bmaptool copy /path/to/core-image-minimal-cubox-i.wic.gz /dev/sdX

or zcat::

    $ zcat /path/to/core-image-minimal-cubox-i.wic.gz | dd of=/dev/sdX

Then power-on the board and log in.
To see that RAUC is configured correctly and can interact
with the bootloader, run::

    # rauc status


IV. Build and Install the Demo Bundle
=====================================

To build the bundle, run::

    $ bitbake update-bundle

Transfer ``update-bundle-cubox-i.raucb`` to the board and install it::

    # rauc install /path/to/update-bundle-cubox-i.raucb

As alternative, you can host the bundle on a web server and update
without downloading it::

    # rauc install http://192.168.1.2/update-bundle-cubox-i.raucb

A convenient way to host HTTP server is::

    $ cd tmp/deploy/images/cubox-i
    $ python3 -m http.server


After the update is complete reboot the board to boot from the updated rootfs.

