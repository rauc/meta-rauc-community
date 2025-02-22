This README file contains information on the contents of the meta-rauc-st-stm32mp layer.

Please see the corresponding sections below for details.

Dependencies
============

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git
* URI: https://github.com/STMicroelectronics/meta-st-stm32mp.git
* URI: https://github.com/STMicroelectronics/meta-st-openstlinux.git

Patches
=======

Please submit any patches against the meta-rauc-st-stm32mp layer via GitHub
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

I. Adding the meta-rauc-st-stm32mp layer to your build
=======================================================

Run 'bitbake-layers add-layer meta-rauc-st-stm32mp'

II. Build The Demo System
=========================

::

   $ source oe-init-build-env

Set the ``MACHINE`` to the model you intend to build for. E.g.::

   MACHINE = "stm32mp15-disco"

Add configuration required for meta-rauc-st-stm32mp to your local.conf::

   DISTRO="openstlinux-weston"
   ENABLE_FLASHLAYOUT_DEFAULT="1"
   FLASHLAYOUT_DEFAULT_SRC = "files/flashlayouts/FlashLayout_sdcard_dual_stm32mp157f-dk2-opteemin.tsv"
   UBOOT_EXTLINUX_KERNEL_ARGS = "rootwait rw rauc.slot=${raucslot}"
   UBOOT_EXTLINUX_ROOT:target-sdcard:stm32mp15-disco="root=PARTLABEL=${bootpart}"
   UBOOT_EXTLINUX_ROOT:target-emmc:stm32mp15-disco="root=PARTLABEL=${bootpart}"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Build the image::

   $ bitbake st-image-core

III. Flash & Run The Demo System
================================

Follow the steps below to flash the image:

* Install STM32CubeProgrammer software for Linux
https://www.st.com/en/development-tools/stm32cubeprog.html#st-get-software

[Follow the installation procedure for DFU mode](https://wiki.stmicroelectronics.cn/stm32mpu/wiki/STM32MP15_Discovery_kits_-_Starter_Package#Image_flashing):

* Set the boot switches to the off position
* Connect the USB Type-C (OTG) port to the host PC that contains the downloaded image
* Insert the delivered microSD card into the dedicated slot 
* Connect the delivered power supply to the USB Type-C port
* Press the reset button to reset the board

* Enter the directory with the image::

  cd tmp-glibc/deploy/images/stm32mp15-disco/

* Flash the image with STM32CubeProgrammer CLI::

  ~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI -c port=usb1 -w flashlayout_st-image-core/FlashLayout_sdcard_dual_stm32mp157f-dk2-opteemin.tsv

* Power off the board, set the boot switches to the on position and power on again the board

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
