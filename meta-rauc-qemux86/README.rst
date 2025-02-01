This README file contains information on the contents of the meta-rauc-qemux86 layer.

Please see the corresponding sections below for details.

Dependencies
============

This layer depends on:

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git

Patches
=======

Please submit any patches against the meta-rauc-qemux86 layer via GitHub
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

I. Adding the meta-rauc-qemux86 layer to your build
===================================================

Run 'bitbake-layers add-layer meta-rauc-qemux86'

II. Build The qemu Demo System
==============================

::

  $ source oe-init-build-env

Add configuration required for qemux86 to your local.conf::

   # Generic qemux86 settings
   MACHINE_FEATURES:append = " pcbios efi"
   EXTRA_IMAGEDEPENDS += "ovmf"

Set the ``MACHINE`` to ``qemux86-64`` if not set yet::

   MACHINE = "qemux86-64"

It is recommended, but not necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

Add configuration required for meta-rauc-qemux86 to your local.conf::

   # Settings for meta-rauc-qemux86
   IMAGE_INSTALL:append = " rauc"
   PREFERRED_RPROVIDER_virtual-grub-bootconf = "rauc-qemu-grubconf"

Make sure either your distro (recommended) or your local.conf have ``rauc``
``DISTRO_FEATURE`` enabled::

   DISTRO_FEATURES:append = " rauc"

You should also enable ``debug-tweaks`` and an ssh server to simplify
interaction with the system::

   EXTRA_IMAGE_FEATURES += "debug-tweaks"
   EXTRA_IMAGE_FEATURES += "ssh-server-openssh"

It is also recommended, but not strictly necessary, to enable 'systemd'::

   INIT_MANAGER = "systemd"

This will place the keys in a directory ``example-ca/`` in your build dir and
configure your ``conf/site.conf`` to let ``RAUC_KEYRING_FILE``,
``RAUC_KEY_FILE`` and ``RAUC_CERT_FILE`` point to this.

Build::

  $ bitbake core-image-minimal

III. Run The qemu Demo System
=============================

Boot qemu image::

    $ runqemu core-image-minimal wic nographic ovmf slirp
    
    ...
    root@qemux86-64:~#

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

Note:
By default using ``slirp`` will forward ports 22 and 23 on the qemu system to ports 2222 and 2323 on the host system.
If there is a collision with another runqemu instance, the script will pick the next free port.
You can define custom port forwarding by setting ``hostfwd`` in ``QB_SLIRP_OPT``. Examples::

    $ QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::<host system port>-:<qemu system port>" runqemu core-image-minimal wic nographic ovmf slirp

    $ QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::2323-:23" runqemu core-image-minimal wic nographic ovmf slirp

Slirp can be useful for remote access to the virtual machine without needing root access to the host machine.
Keep in mind firewalls on both the host and the qemu machines should be configured based on your needs.

IV. Build and Install The Demo Bundle
=====================================

To build the bundle, run::

  $ bitbake qemu-demo-bundle

Obtain an IP address on the target::

    # udhcpc -i eth0

Copy update Bundle from host to the target::

    $ scp -P 2222 tmp/deploy/images/qemux86-64/qemu-demo-bundle-qemux86-64.raucb root@localhost:/tmp

Check Bundle on the target::

    # rauc info /tmp/qemu-demo-bundle-qemux86-64.raucb

Install the Bundle::

    # rauc install /tmp/qemu-demo-bundle-qemux86-64.raucb
    installing
      0% Installing
      0% Determining slot states
     20% Determining slot states done.
     20% Checking bundle
     20% Verifying signature
     40% Verifying signature done.
     40% Checking bundle done.
     40% Checking manifest contents
     60% Checking manifest contents done.
     60% Determining target install group
     80% Determining target install group done.
     80% Updating slots
     80% Checking slot efi.0
     85% Checking slot efi.0 done.
     85% Copying image to efi.0
     90% Copying image to efi.0 done.
     90% Checking slot rootfs.1
     95% Checking slot rootfs.1 done.
     95% Copying image to rootfs.1
     100% Copying image to rootfs.1 done.
     100% Updating slots done.
     100% Installing done.
     Installing `/tmp/qemu-demo-bundle-qemux86-64.raucb` succeeded

Reboot the system::

    # systemctl reboot

A. Using 'kas' Tool to Build
============================

::

  $ git clone https://github.com/rauc/meta-rauc-community.git
  $ kas checkout meta-rauc-community/meta-rauc-qemux86/kas-qemu-grub.yml
  $ kas shell meta-rauc-community/meta-rauc-qemux86/kas-qemu-grub.yml
  % ../create-example-keys.sh
  % bitbake core-bundle-minimal

