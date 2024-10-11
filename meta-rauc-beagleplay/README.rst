This README file contains information on the contents of the meta-rauc-beagplay
layer.

Please see the corresponding sections below for details.

Dependencies
============

* URI: https://git.yoctoproject.org/poky/
* URI: https://github.com/rauc/meta-rauc.git
* URI: git://git.yoctoproject.org/meta-arm
* URI: git://git.yoctoproject.org/meta-ti
* URI: git@github.com:rauc/meta-rauc.git
* URI: git@github.com:rauc/meta-rauc-community.git

Patches
=======

Please submit any patches against the meta-rauc-beagleplay layer via GitHub
pull request on https://github.com/rauc/meta-rauc-community.

Maintainer: Leon Anavi <leon.anavi@konsulko.com>

Disclaimer
==========

Note that this is just an example layer that shows a few possible configuration
options how RAUC can be used.
Actual requirements may differ from project to projects and will probably need
a much different RAUC/bootloader/system configuration.

Also note that this layer is for demo purpose only and does not care about
migratability between different layer revisions.

I. Adding the required layers to your build
=======================================================

::
  mkdir sources
  cd sources
  git clone -b scarthgap git://git.yoctoproject.org/poky
  git clone -b scarthgap git://git.yoctoproject.org/meta-ti
  git clone -b scarthgap git://git.yoctoproject.org/meta-arm
  git clone -b scarthgap git@github.com:rauc/meta-rauc.git
  git clone -b scarthgap git@github.com:amsobr/meta-rauc-community.git


From the root of the build tree, run:

::
  . sources/poky/oe-init-build-env

  bitbake-layers add-layer ../sources/meta-arm/meta-arm-toolchain/
  bitbake-layers add-layer ../sources/meta-arm/meta-arm
  bitbake-layers add-layer ../sources/meta-ti/meta-ti-bsp/
  bitbake-layers add-layer ../sources/meta-rauc/
  bitbake-layers add-layer ../sources/meta-rauc-community/meta-rauc-beagleplay/

Modify `conf/local.conf` and add at the end:

::
  # Saves a **lot** of disk space by removing the work dir after finished building recipes.
  INHERIT += "rm_work"

  DISTRO_FEATURES:append = " rauc"
  MACHINE ?= "beagleplay"

II. Build The Demo System
=========================

To build the eMMC image for the internal eMMC storage of the beagleplay, run:

::
  source sources/poky/oe-init-build-env
  bitbake core-image-minimal

To build the  eMMC flasher image, run:

::
  bitbake emmc-flasher-image

III. Flash & Run The Demo System
================================

Transfer the flasher image into an SD card (replace **/dev/sdX** with the actual
block device)

::
  dd if=deploy-ti/images/beagleplay/emmc-flasher-image.rootfs.wic of=/dev/sdX bs=4k

Then insert the SD card in the BeaglePlay, keep the USR button pushed  and
power-on the the board. Wait until the flasher completes and the board
powers-down

IV: Verify that RAUC is enabled and working
===========================================

Power-off the board, remove the SD card and power-on the board again. Not it
will boot from the eMMC.

Log into the board and run:

::
  rauc status

V. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake update-bundle

Copy the generated bundle to the target system via nc, scp or an attached USB stick.

On the target, you can then install the bundle::

  # rauc install /path/to/bundle.raucb
