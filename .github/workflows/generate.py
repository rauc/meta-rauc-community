#!/usr/bin/env python3

from jinja2 import Template

TEMPLATE = """
name: «« layer »» CI

on:
  # Trigger the workflow on push or pull request,
  # but only for the master branch
  push:
    branches:
      - master
    paths:
      - '.github/workflows/«« layer »».yml'
      - '«« layer »»/**'
  pull_request:
    branches:
      - master
    paths:
      - '.github/workflows/«« layer »».yml'
      - '«« layer »»/**'
  # allow rebuilding without a push
  workflow_dispatch: {}

jobs:
  build:
    name: «« layer »» Build
    runs-on: ubuntu-20.04
    steps:
      - name: Install required packages
        run: |
          sudo apt-get install diffstat
      - name: Checkout
        uses: actions/checkout@v3
      «% for name, url in base_layers.items()|list + extra_layers.items()|list %»
      - name: Clone «« name »»
        run: git clone -b master «« url »»
      «% endfor %»
      - name: Initialize build directory
        run: |
          source poky/oe-init-build-env build
          bitbake-layers add-layer ../meta-rauc
          «% for name in extra_layers.keys() %»
          bitbake-layers add-layer ../«« name »»
          «% endfor %»
          bitbake-layers add-layer ../«« layer »»
          echo 'INHERIT += "rm_work"' >> conf/local.conf
          echo 'DISTRO_FEATURES:remove = "alsa bluetooth usbgadget usbhost wifi nfs zeroconf pci 3g nfc x11 opengl ptest wayland vulkan"' >> conf/local.conf
          echo 'SSTATE_MIRRORS = "file://.* http://195.201.147.117/sstate-cache/PATH"' >> conf/local.conf
          «% if machine %»
          echo 'MACHINE = "«« machine »»"' >> conf/local.conf
          «% endif %»
          echo 'DISTRO_FEATURES:append = " rauc"' >> conf/local.conf
          echo 'IMAGE_INSTALL:append = " rauc"' >> conf/local.conf
          echo 'IMAGE_FSTYPES = "«« fstypes »»"' >> conf/local.conf
          echo 'WKS_FILE = "«« wks_file »»"' >> conf/local.conf
          «% for line in conf %»
          echo '«« line »»' >> conf/local.conf
          «% endfor %»
      - name: bitbake parsing test
        run: |
          source poky/oe-init-build-env build
          bitbake -p
""".lstrip()

template = Template(
    TEMPLATE,
    block_start_string="«%",
    block_end_string="%»",
    variable_start_string="««",
    variable_end_string="»»",
    comment_start_string="«#",
    comment_end_string="#»",
    trim_blocks=True,
    lstrip_blocks=True,
    keep_trailing_newline=True,
)

default_context = {
    "base_layers": {
        "poky": "git://git.yoctoproject.org/poky",
        "meta-rauc": "https://github.com/rauc/meta-rauc.git",
    },
    "extra_layers": {},
    "machine": None,
    "conf": [],
}

contexts = [
    {
        **default_context,
        "layer": "meta-rauc-qemux86",
        "fstypes": "tar.bz2 wic",
        "wks_file": "qemux86-grub-efi.wks",
        "conf": [
            'EXTRA_IMAGEDEPENDS += "ovmf"',
            'PREFERRED_RPROVIDER_virtual-grub-bootconf = "rauc-qemu-grubconf"',
        ],
    },
    {
        **default_context,
        "layer": "meta-rauc-raspberrypi",
        "extra_layers": {
            "meta-raspberrypi": "git://git.yoctoproject.org/meta-raspberrypi",
        },
        "machine": "raspberrypi4",
        "fstypes": "ext4",
        "wks_file": "sdimage-dual-raspberrypi.wks.in",
    },
]

for context in contexts:
    output = template.render(context)
    file_name = f"{context['layer']}.yml"
    with open(file_name, "w") as file:
        file.write(output)
    print(f"generated {file_name}")
