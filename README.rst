|MIT| |Matrix|

RAUC Demo Layers
================


* meta-rauc-nxp: RAUC demo layer for NXP hardware (meta-freescale)
* meta-rauc-qemux86: RAUC demo layer for qemux86-64
* meta-rauc-raspberrypi: RAUC demo layer for the Raspberry PI (meta-raspberrypi)
* meta-rauc-sunxi: RAUC demo layer for the Allwinner sunxi SoCs (meta-sunxi)
* meta-rauc-tegra: RAUC demo layer for NVIDIA Jetson platforms, based on L4T (meta-tegra)

The layers perform the required integration steps for setting up a redundant
boot with RAUC:

* Add bootloader boot logic script
* Set up bootloader storage/environment
* Provide example wic image config
* Provide proper rauc system.conf
* Add example keys

.. |MIT| image:: https://img.shields.io/badge/license-MIT-blue.svg
   :target: https://raw.githubusercontent.com/rauc/meta-rauc-community/master/COPYING.MIT
.. |Matrix| image:: https://img.shields.io/matrix/rauc:matrix.org?label=matrix%20chat
   :target: https://app.element.io/#/room/#rauc:matrix.org
