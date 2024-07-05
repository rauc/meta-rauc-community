|MIT| |Matrix|

RAUC Demo Layers
================

This is a community-driven layer collection meant to pave the way for others to
evaluate RAUC or to integrate it into their own projects.

Each layer is maintained independently from the other, thus the quality and
topicality of the layers may differ.

Also note that they only provide **an example** of how RAUC could be
integrated.
Depending on your project's needs, your actual integration may significantly
differ in some aspects.

Currently available meta layers are:

* `meta-rauc-nxp <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-nxp>`_:
  RAUC demo layer for NXP hardware (meta-freescale)
* `meta-rauc-qemux86 <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-qemux86>`_:
  RAUC demo layer for qemux86-64
* `meta-rauc-raspberrypi <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-raspberrypi>`_:
  RAUC demo layer for the Raspberry Pi (meta-raspberrypi)
* `meta-rauc-sunxi <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-sunxi>`_:
  RAUC demo layer for the Allwinner sunxi SoCs (meta-sunxi)
* `meta-rauc-tegra <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-tegra>`_:
  RAUC demo layer for NVIDIA Jetson platforms, based on L4T (meta-tegra)
* `meta-rauc-rockchip <https://github.com/rauc/meta-rauc-community/tree/master/meta-rauc-rockchip>`_:
  RAUC demo layer for Rock Pi 4 Model B and other Rockchip devices

The layers perform the required integration steps for setting up a redundant
boot with RAUC:

* Add bootloader boot logic script
* Set up bootloader storage/environment
* Provide example wic image config
* Provide proper rauc system.conf
* Add example keys

Contributing
============

To report bugs for an existing layer, file a new `issue
<https://github.com/rauc/meta-rauc-community/issues>`_ on GitHub.

For fixing bugs on existing layers, bumping the version compatibility, or
adding new features, open a `pull request
<https://github.com/rauc/meta-rauc-community/pulls>`_ on GitHub.

Add a ``Signed-off-by`` line to your commits according to the
`Developer’s Certificate of Origin
<https://github.com/rauc/meta-rauc-community/blob/master/DCO>`_.

Contributions of new layers are always welcome.
Here are some advices to consider when adding a new layer:

* If there is a already an existing layer for a similar platform check if that
  can be extended
* Make sure your integration follows recent recommendations for RAUC
  `integration <https://rauc.readthedocs.io/en/latest/integration.html#>`_
* Provide at least a minimal README.rst to allow others to reproduce your work
* It would be highly appreciated if created layers could be maintained over
  time

.. |MIT| image:: https://img.shields.io/badge/license-MIT-blue.svg
   :target: https://raw.githubusercontent.com/rauc/meta-rauc-community/master/COPYING.MIT
.. |Matrix| image:: https://img.shields.io/matrix/rauc:matrix.org?label=matrix%20chat
   :target: https://app.element.io/#/room/#rauc:matrix.org
