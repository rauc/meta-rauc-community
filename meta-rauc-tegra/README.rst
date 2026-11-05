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

Supported machines
==================

===================================  ============  ==========================
Machine                              Bootloader    Notes
===================================  ============  ==========================
``jetson-tx2-devkit``                U-Boot        cboot, environment on eMMC
``jetson-orin-nano-devkit``          UEFI          SD card, see section V
``jetson-orin-nano-devkit-nvme``     UEFI          NVMe, see section V
===================================  ============  ==========================

The recipes shared by the machines select their configuration through machine
overrides (``tegra186`` for the Jetson TX2, ``jetson-orin-nano-devkit`` for both
Orin Nano devkits).

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

   MACHINE = "jetson-orin-nano-devkit-nvme"

Add configuration required for meta-rauc-tegra to your local.conf::

   # Split rootfs size for meta-rauc-tegra
   ROOTFSPART_SIZE = "15032385536"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"
   IMAGE_INSTALL:append = " rauc"

For Orin Nano devkits (jetson-orin-nano-devkit and jetson-orin-nano-devkit-nvme), 
the following settings are required for RAUC A/B updates:

   # Image: the ext4 rootfs is the content of the update bundle.
   IMAGE_FSTYPES:append = " ext4"

   # Flash layout: A/B partitions (APP / APP_b), required by the slot layout.
   USE_REDUNDANT_FLASH_LAYOUT_DEFAULT = "1"

For the ``jetson-orin-nano-devkit`` (SD card) machine also set the size of the
SD card image and install ``mkfs.ext4``, as the ``DATA`` partition is then
formatted on first boot (``x-systemd.makefs``) instead of at flash time::

   TEGRAFLASH_SDCARD_SIZE = "32G"
   IMAGE_INSTALL:append = " e2fsprogs-mke2fs"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Build the minimal system image::

   $ bitbake core-image-minimal

Please note that NVIDIA Jetson TX2 has a very specific boot flow: cboot
boots u-boot which boots the kernel and the u-boot environment is on the eMMC.
This may affect RAUC atomic bootloader updates therefore for production-ready
devices it is recommended to adjust the location of the u-boot environment.

The following variables are weak defaults and can be overridden in local.conf:

================================  ============================================================================
Variable                          Description
================================  ============================================================================
``RAUC_KEY_FILE``                 Bundle signing key
``RAUC_CERT_FILE``                Bundle signing certificate
``DATA_MOUNT_POINT``              Mount point of the persistent partition (default ``/data``)
``DATA_PART_ENABLE``              Add the ``DATA`` partition to the flash layout (default ``1``)
``DATA_PART_NAME``                Partition label (default ``DATA``)
``DATA_PART_ID``                  Explicit GPT partition id (default ``11``, or ``17`` if the kernel partitions are kept)
``DATA_PART_FSTYPE``              Filesystem created at flash time (default ``ext4``)
``REMOVE_KERNEL_PARTITIONS``      Remove the stock kernel partitions from the flash layout (default ``1``)
``KERNEL_PARTITIONS_TO_REMOVE``   Partitions removed when the above is ``1``
================================  ============================================================================

III. Flash & Run The Demo System
================================

Jetson TX2
----------

Turn on jetson-tx2-devkit in a recovery mode connected to a PC with USB to microUSB cable and flash the image::

  $ jetsondir=$(mktemp -d /tmp/jetson.XXXXXXXX)
  $ tar -xf core-image-minimal-jetson-tx2-devkit.tegraflash.tar.gz -C $jetsondir
  $ cd $jetsondir
  $ sudo ./doflash.sh

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

Jetson Orin Nano devkits
------------------------

Flash the device with the generated ``tegraflash`` package (or the SD card
image) as described in the meta-tegra documentation.

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

Optional: factory-provisioned ``/data`` (Orin Nano devkits)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default the ``DATA`` partition is formatted empty at flash time. Setting
``RAUC_TEGRA_DATAIMG_SIZE_MB`` globally makes the flash package carry an ext4
image for it instead, built by ``classes/rauc-dataimg-tegra.bbclass`` from
the files the image installs below ``/data`` (these are kept out of the rootfs
slots and of the bundle). The class has to be inherited by the flashed image::

  RAUC_TEGRA_DATAIMG_SIZE_MB = "256"
  IMAGE_CLASSES:append:pn-core-image-minimal = " rauc-dataimg-tegra"

The partition still fills the rest of the device; the filesystem is grown to it
on first mount (``x-systemd.growfs``). ``kas/data-image.yml`` is an overlay doing
this and installing the sample package ``rauc-data-sample``.

IV. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake update-bundle

Copy the generated bundle to the target system via nc, scp or an attached USB stick.

On the target, you can then install the bundle::

  # rauc install /path/to/update-bundle-jetson-tx2-devkit.raucb

or, for the Orin Nano devkits (e.g. the NVMe machine)::

  # rauc install /path/to/update-bundle-jetson-orin-nano-devkit-nvme.raucb

**Security note:** the key and certificate in
``recipes-core/bundles/files`` and the keyring in
``recipes-core/rauc/files`` (shared by all machines) are for development only.
Override ``RAUC_KEY_FILE`` / ``RAUC_CERT_FILE`` and replace the keyring for
production, and do not ship the development key.
