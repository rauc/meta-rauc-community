This README file contains information on the contents of the meta-rauc-raspberrypi layer.

Please see the corresponding sections below for details.

Dependencies
============

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc
* URI: https://github.com/agherzan/meta-raspberrypi

If you want to build for Raspberry Pi 5 you will also need meta-lts-mixins:

* URI: git://git.yoctoproject.org/meta-lts-mixins
* branch: scarthgap/u-boot

Patches
=======

Please submit any patches against the meta-rauc-raspberrypi layer via GitHub
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

I. Adding the meta-rauc-raspberrypi layer to your build
=======================================================

Run 'bitbake-layers add-layer meta-rauc-raspberrypi'

II. Build The Demo System
=========================

::

   $ source oe-init-build-env

Add configuration required for meta-raspberrypi to your local.conf::

   # Generic raspberrypi settings
   ENABLE_UART = "1"
   RPI_USE_U_BOOT = "1"

Set the ``MACHINE`` to the model you intend to build for. E.g.::

   MACHINE = "raspberrypi4"

or::

   MACHINE = "raspberrypi3"

Add configuration required for meta-rauc-raspberrypi to your local.conf::

   # Settings for meta-rauc-raspberry-pi
   IMAGE_INSTALL:append = " rauc"
   IMAGE_FSTYPES:append = " ext4"
   WKS_FILE = "sdimage-dual-raspberrypi.wks.in"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Create example authentication keys (from sourced environment)::

  $ ../meta-rauc-community/create-example-keys.sh

This will place the keys in a directory ``example-ca/`` in your build dir and
configure your ``conf/site.conf`` to let ``RAUC_KEYRING_FILE``,
``RAUC_KEY_FILE`` and ``RAUC_CERT_FILE`` point to this.

Build the minimal system image::

   $ bitbake core-image-minimal

III. Flash & Run The Demo System
================================

You can either flash using bmaptool (recommended)::

  $ bmaptool copy /path/to/core-image-minimal-raspberrypi3.wic.bz2 /dev/sdX

or bzcat::

  $ bzcat /path/to/core-image-minimal-raspberrypi3.wic.bz2 | dd of=/dev/sdb

Then power-on the board and log in.
To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

IV. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake update-bundle

Copy the generated bundle to the target system via nc, scp or an attached USB stick.

On the target, you can then install the bundle::

  # rauc install /path/to/bundle.raucb
