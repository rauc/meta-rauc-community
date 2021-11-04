RAUC Demo Layers
================


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
