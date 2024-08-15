This README file contains information on the contents of the meta-rauc-rockchip layer.

Please see the corresponding sections below for details.

Dependencies
============

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git
* URI: https://git.yoctoproject.org/poky/
* URI: https://git.yoctoproject.org/meta-arm
* URI: https://git.yoctoproject.org/meta-rockchip/

Patches
=======

Please submit any patches against the meta-rauc-rockchip layer via GitHub
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

I. Adding the meta-rauc-rockchip layer to your build
=======================================================

Run 'bitbake-layers add-layer meta-rauc-rockchip'

II. Build The Demo System
=========================

::

   $ source oe-init-build-env

Set the ``MACHINE`` to the model you intend to build for. E.g.::

   MACHINE = "rock-pi-4b"

Add configuration required for meta-rauc-rockchip to your local.conf::

   # Settings for meta-rauc-rockchip
   SERIAL_CONSOLES="115200;ttyS2"
   IMAGE_FSTYPES:append = " ext4"
   WKS_FILE = "rockchip-dual.wks.in"
   MACHINE_FEATURES:append = " rk-u-boot-env"
   UBOOT_EXTLINUX_KERNEL_IMAGE="/${KERNEL_IMAGETYPE}"
   UBOOT_EXTLINUX_ROOT="root=PARTLABEL=${bootpart}"
   UBOOT_EXTLINUX_KERNEL_ARGS = "rootwait rw rootfstype=ext4 rauc.slot=${raucslot}"
   WIC_CREATE_EXTRA_ARGS = "--no-fstab-update"

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

   $ bitbake core-image-base

III. Flash & Run The Demo System
================================

You can either flash using bmaptool (recommended)::

  $ bmaptool copy /path/to/core-image-base-rock-pi-4b.rootfs.wic /dev/sdX

or bzcat::

  $ bzcat /path/to/core-image-base-rock-pi-4b.rootfs.wic | dd of=/dev/sdb

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
