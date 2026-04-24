This README file contains information on the contents of the meta-rauc-genericx86-64 layer.

Please see the corresponding sections below for details.

Dependencies
============

This layer depends on:

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git

Patches
=======

Please submit any patches against the meta-rauc-genericx86-64 layer via GitHub
pull request on https://github.com/rauc/meta-rauc-community.

Maintainer: Leon Anavi <leon.anavi@konsulko.com>

Features
========

* A+B+recovery system example configuration
* GRUB bootsource selection
* Atomic EFI bootloader (GRUB) updates
* Shared data partition (with RAUC central slot status)
* Example bundle recipe
* Ready for testing RAUC adaptive updates

I. Adding the meta-rauc-genericx86-64 layer to your build
===================================================

Run 'bitbake-layers add-layer meta-rauc-genericx86-64'

II. Build The qemu Demo System
==============================

::

  $ source oe-init-build-env

Add configuration required for genericx86-64 to your local.conf::

   # Generic genericx86-64 settings
   MACHINE_FEATURES:append = " pcbios efi"
   EXTRA_IMAGEDEPENDS += "ovmf"

Set the ``MACHINE`` to ``genericx86-64-64`` if not set yet::

   MACHINE = "genericx86-64-64"

It is recommended, but not necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Add configuration required for meta-rauc-genericx86-64 to your local.conf::

   # Settings for meta-rauc-genericx86-64
   IMAGE_INSTALL:append = " rauc"
   PREFERRED_RPROVIDER_virtual-grub-bootconf = "rauc-qemu-grubconf"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"

You should also enable some debug tweaks and an ssh server to simplify
interaction with the system::

   EXTRA_IMAGE_FEATURES += "allow-empty-password allow-root-login empty-root-password"
   EXTRA_IMAGE_FEATURES += "ssh-server-openssh"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

This will place the keys in a directory ``example-ca/`` in your build dir and
configure your ``conf/site.conf`` to let ``RAUC_KEYRING_FILE``,
``RAUC_KEY_FILE`` and ``RAUC_CERT_FILE`` point to this.

Build::

  $ bitbake core-image-base

III. Run The qemu Demo System
=============================

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

IV. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake update-bundle

Obtain an IP address on the target::

    # busybox httpd -p 8000 -f -v

On the target, replace `x.x.x.x` with the IP of the server from the same network and install the bundle:::

    # rauc install http://x.x.x.x:8000/update-bundle-genericx86-64-64.raucb

Reboot the system::

    # systemctl reboot

