This README file contains information on the contents of the meta-rauc-sunxi layer.

Please see the corresponding sections below for details.

Dependencies
============

  URI: https://git.yoctoproject.org/poky
  branch: scarthgap

  URI: https://github.com/rauc/meta-rauc.git
  branch: scarthgap

  URI: https://git.yoctoproject.org/meta-arm
  branch: scarthgap

  URI: https://github.com/linux-sunxi/meta-sunxi.git
  branch: scarthgap

  URI: https://github.com/Freescale/meta-freescale-distro.git
  branch: scarthgap


Patches
=======

Please submit any patches against the meta-rauc-sunxi layer via GitHub
pull requests on https://github.com/rauc/meta-rauc-community.

Maintainer: Leon Anavi <leon.anavi@konsulko.com>


Disclaimers
===========

Note that this is just an example layer that shows a possible RAUC
configuration.
Actual requirements may differ from project to project and will
probably need a much different RAUC/bootloader/system configuration.


Currently this layer supports:

- Olimex A10-OLinuXino-LIME
- Olimex A20-OLinuXino-MICRO
- Orange Pi One
- Orange Pi Zero


I. Adding the meta-rauc-sunxi layer to your build
===============================================

Run 'bitbake-layers add-layer meta-rauc-sunxi'


II. Build Sunxi Demo System
===============================================

For Olimex A10-OLinuXino-LIME follow the steps below:

::

    $ . oe-init-build-env

Set ``MACHINE`` to ``olinuxino-a10lime`` in your local.conf::

    MACHINE = "olinuxino-a10lime"

Enable 'systemd'::

    INIT_MANAGER = "systemd"

Add configuration required for RAUC to your local.conf::

    IMAGE_FSTYPES:append = " ext4"
    DISTRO_FEATURES:append = " rauc"

Select the Kickstart file::

    WKS_FILE = "sunxi-dual-image.wks.in"
    WKS_FILES = "sunxi-dual-image.wks.in"

You can increase the size of rootfs to contain software added when updating::

    # Add 150 000 Kbytes free space to rootfs
    IMAGE_ROOTFS_EXTRA_SPACE:append = " + 150000"

You can enable automatic resize of the data partition on the first boot::

    IMAGE_INSTALL:append = " rauc-grow-data-part"

Build the minimal system image::

    $ bitbake core-image-base


III. Flash & Run the Demo System
================================

Before flashing it's recommended to make sure that any traces
of u-boot environment that may have been left from prevous use
of the SD card are erased::

    $ dd if=/dev/zero of=/dev/sdX count=10000

You can either flash using bmaptool (recommended)::

    $ bmaptool copy /path/to/core-image-base-olinuxino-a10lime.rootfs.wic.gz /dev/sdX

or zcat::

    $ zcat /path/to/core-image-base-olinuxino-a10lime.rootfs.wic.gz | dd of=/dev/sdX

Then power-on the board and log in.
To see that RAUC is configured correctly and can interact
with the bootloader, run::

    # rauc status


IV. Build and Install the Demo Bundle
=====================================

To build the bundle, run::

    $ bitbake update-bundle

Transfer ``update-bundle-olinuxino-a10lime.raucb`` to the board and install it::

    # rauc install /path/to/update-bundle-olinuxino-a10lime.raucb

As alternative, you can host the bundle on a web server and update
without downloading it::

    # rauc install http://192.168.1.2/update-bundle-olinuxino-a10lime.raucb

A convenient way to host HTTP server is::

    $ cd tmp/deploy/images/olinuxino-a10lime
    $ python3 -m RangeHTTPServer

Alternatively, another convenient way to host HTTP server is::

    $ cd tmp/deploy/images/olinuxino-a10lime
    $ busybox httpd -p 8000 -f -v

After the update is complete reboot the board to boot from the updated rootfs.

