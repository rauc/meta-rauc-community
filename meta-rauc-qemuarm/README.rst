Dependencies
============

This layer depends on:

* URI: git://git.openembedded.org/openembedded-core
* URI: https://github.com/rauc/meta-rauc.git

Patches
=======

Please submit any patches against the meta-rauc-qemuarm layer via GitHub
pull request on https://github.com/rauc/meta-rauc-community.

Maintainer: Joschka Seydell <joschka@seydell.org>

Features
========

* A+B+recovery system example configuration
* u-boot boot source selection using a bootscript
* Shared data partition (with RAUC central slot status)
* Example bundle recipe

I. Adding the meta-rauc-qemuarm layer to your build
===================================================

Run 'bitbake-layers add-layer meta-rauc-qemuarm'

II. Build the qemu demo system
==============================

::

  $ source oe-init-build-env

Set the ``MACHINE`` to ``qemuarm64`` or your custom configuration based on that::

   MACHINE = "qemuarm64"

Note: This layer also supports the ``qemuarm`` machine, but defaults to aarch64.
Be sure to adjust the machine specific configuration when using the 32-bit variant.

Make sure either your machine (recommended) or your ``local.conf`` configure the
``u-boot`` related options::
   
   PREFERRED_PROVIDER_virtual/bootloader = "u-boot"

Similarly, enable ``rauc`` either in your distro (recommended) or your ``local.conf``
as ``DISTRO_FEATURE`` and properly configure the user space interface to ``u-boot``::

   DISTRO_FEATURES:append = " rauc"
   PREFERRED_RPROVIDER_u-boot-default-env = "libubootenv"

If you also want to used ``systemd``, you should also add::

   INIT_MANGER = "systemd"

To properly support the ``qcow2`` image format used in the demo and ``u-boot`` as bootloader,
you need to provide the following qemu boot option::
 
   QB_DEFAULT_BIOS:qemuarm64 = "u-boot.bin"
   QB_ROOTFS_OPT:qemuarm64 = "-drive id=disk0,file=@ROOTFS@,if=none,format=qcow2 -device virtio-blk-device,drive=disk0"
   QB_OPT_APPEND:qemuarm64 += " -drive if=pflash,format=raw,index=1,file=${TMPDIR}/deploy/images/${MACHINE}/bootenv.img"

The last line makes the bootloader environment persisting reboots.
If you want to increase the memory available to your emulated system, you can
add something like ``QB_MEM:qemuarm64 = "-m 3G"`` here, too.

You should also enable some debug tweaks and an ssh server in your
``local.conf`` to simplify interaction with the system::

   EXTRA_IMAGE_FEATURES += "allow-empty-password allow-root-login empty-root-password"
   EXTRA_IMAGE_FEATURES += "ssh-server-openssh"

This will place the keys in a directory ``example-ca/`` in your build dir and
configure your ``conf/site.conf`` to let ``RAUC_KEYRING_FILE``,
``RAUC_KEY_FILE`` and ``RAUC_CERT_FILE`` point to this.

Build::

  $ bitbake core-image-minimal

III. Run the qemu demo system
=============================

Boot the qemu image::

    $ runqemu core-image-minimal wic.qcow2 nographic slirp
    
    ...
    root@qemuarm64:~#

To see that RAUC is configured correctly and can interact with the bootloader,
run::

  # rauc status

Note:
By default using ``slirp`` will forward ports 22 and 23 on the qemu system to ports 2222 and 2323 on the host system.
If there is a collision with another runqemu instance, the script will pick the next free port.
You can define custom port forwarding by setting ``hostfwd`` in ``QB_SLIRP_OPT``. Examples::

    $ export QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::<host system port>-:<qemu system port>"

    $ export QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::2323-:23"

Slirp can be useful for remote access to the virtual machine without needing root access to the host machine.
Keep in mind firewalls on both the host and the qemu machines should be configured based on your needs.

IV. Build and install the update bundle
=======================================

To build the bundle, run::

  $ bitbake update-bundle

Obtain an IP address on the target::

    # udhcpc -i eth0

Copy update the bundle from your host to the target::

    $ scp -P 2222 tmp/deploy/images/qemuarm64/update-bundle-qemuarm64.raucb root@localhost:/tmp

Check the bundle on the target::

    # rauc info /tmp/update-bundle-qemuarm64.raucb

Install the bundle::

    # rauc install /tmp/update-bundle-qemuarm64.raucb
    
Reboot the system::

    # systemctl reboot

A. Using the 'kas' tool to build
================================

::

  $ git clone https://github.com/rauc/meta-rauc-community.git
  $ kas checkout meta-rauc-community/meta-rauc-qemuarm/kas-qemuarm.yml
  $ kas shell meta-rauc-qemuarm/kas-qemuarm.yml
  $ ../create-example-keys.sh
  $ bitbake core-bundle-minimal


Note: If you're using the `kas-container` virtualization, things work slightly different.