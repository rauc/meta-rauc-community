This README file contains information on the contents of the meta-rauc-tega layer.

Please see the corresponding sections below for details.

Dependencies
============

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git
* URI: https://github.com/OE4T/meta-tegra

Patches
=======

Please submit any patches against the meta-rauc-tegra layer via GitHub
pull request on https://github.com/rauc/meta-rauc-community.

Maintainer: Leon Anavi <leon.anavi@konsulko.com>

Disclaimer
==========

Note that this is just an example layer that shows a few possible configuration
options how RAUC can be used.
Actual requirements may differ from project to projects and will probably need
a much different RAUC/bootloader/system configuration.

Also note that this layer is for demo purpose only and does not care about
migratability between different layer revision.

I. Adding the meta-rauc-tegra layer to your build
=======================================================

Run 'bitbake-layers add-layer meta-rauc-tegra'

II. Build The Demo System
=========================

::

   $ source oe-init-build-env

Add configuration required for meta-tegra to your local.conf::

   # Generic tegra settings
   LICENSE_FLAGS_WHITELIST = "commercial"
   IMAGE_CLASSES += "image_types_tegra"
   IMAGE_FSTYPES = "tegraflash"
   NVIDIA_DEVNET_MIRROR = "file:///path/to/your/nvidia/sdkm_downloads"

Set the ``MACHINE`` to the model you intend to build for. E.g.::

   MACHINE = "jetson-tx2-devkit"

Add configuration required for meta-rauc-tegra to your local.conf::

   # Split rootfs size for jetson-tx2-devkit meta-rauc-tegra
   ROOTFSPART_SIZE = "15032385536"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"
   IMAGE_INSTALL:append = " rauc"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Build the minimal system image::

   $ bitbake core-image-minimal

Please note that NVIDIA Jetson TX2 has a very specific boot flow: cboot
boots u-boot which boots the kernel and the u-boot environment is on the eMMC.
This may affect RAUC atomic bootloader updates therefore for production-ready
devices it is recommended to adjust the location of the u-boot environment.

III. Flash & Run The Demo System
================================

Turn on jetson-tx2-devkit in a recovery mode connected to a PC with USB to microUSB cable and flash the image::

  $ jetsondir=$(mktemp -d /tmp/jetson.XXXXXXXX)
  $ tar -xf core-image-minimal-jetson-tx2-devkit.tegraflash.tar.gz -C $jetsondir
  $ cd $jetsondir
  $ sudo ./doflash.sh

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

IV. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake update-bundle

Copy the generated bundle to the target system via nc, scp or an attached USB stick.

On the target, you can then install the bundle::

  # rauc install /path/to/update-bundle-jetson-tx2-devkit.raucb
