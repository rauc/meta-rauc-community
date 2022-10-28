#
# Copyright (C) 2013 - 2018 Wind River Systems, Inc.
#
PCMCIA_MANAGER = "pcmciautils"
PREFERRED_PROVIDER_virtual/xserver ?= "xserver-kdrive"
PREFERRED_PROVIDER_virtual/libgl ?= "mesa"

MACHINE_FEATURES = "alsa pcmcia bluetooth irda usbgadget screen"

IMAGE_FSTYPES += "tar.bz2"

