#!/usr/bin/env python3

from jinja2 import Template

TEMPLATE = """
name: build «« layer »»

on:
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
    # run on self-hosted runner for the main repo or if vars.BUILD_RUNS_ON is set
    runs-on: >-
      ${{
        (vars.BUILD_RUNS_ON != ''  && fromJSON(vars.BUILD_RUNS_ON)) ||
        (github.repository == 'rauc/meta-rauc-community' && fromJSON('["self-hosted", "forrest", "build"]')) ||
        'ubuntu-20.04'
      }}
    steps:
      - name: Install required packages
        run: |
          sudo apt-get -q -y --no-install-recommends install diffstat tree
      - name: Checkout
        uses: actions/checkout@v4
      «% for layer_name, layer_info in layers.items() %»
      - name: Clone «« layer_name »»
        run: git clone --shared --reference-if-able /srv/shared-git/«« layer_name »».git -b «« layer_info["branch"] | default(release) »» «« layer_info["repo"] »»
      «% endfor %»
      - name: Initialize build directory
        run: |
          source poky/oe-init-build-env build
          «% for layer_path in add_layers %»
          bitbake-layers add-layer ../«« layer_path »»
          «% endfor %»
          bitbake-layers add-layer ../«« layer »»
          if [ -f ~/.yocto/auto.conf ]; then
            cp ~/.yocto/auto.conf conf/
            echo 'SOURCE_MIRROR_URL = "http://10.0.2.2/rauc-community/downloads"' >> conf/auto.conf
          else
            echo 'SSTATE_MIRRORS = "file://.* https://github-runner.pengutronix.de/rauc-community/sstate-cache/PATH"' >> conf/auto.conf
            echo 'BB_SIGNATURE_HANDLER = "OEBasicHash"' >> conf/auto.conf
            echo 'BB_HASHSERVE = ""' >> conf/auto.conf
            echo 'OPKGBUILDCMD = "opkg-build -Z gzip -a -1n"' >> conf/auto.conf
            echo 'INHERIT += "rm_work"' >> conf/auto.conf
          fi
          echo 'DISTRO_FEATURES:remove = "alsa bluetooth usbgadget usbhost wifi nfs zeroconf pci 3g nfc x11 opengl ptest wayland vulkan"' >> conf/local.conf
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
      - name: Show configuration files
        run: |
          cd build/conf
          rgrep . *.conf
      - name: Test bitbake parsing
        run: |
          source poky/oe-init-build-env build
          bitbake -p
      - name: Build rauc, rauc-native
        run: |
          source poky/oe-init-build-env build
          bitbake rauc rauc-native
      - name: Build «« image »»
        run: |
          source poky/oe-init-build-env build
          bitbake «« image »»
      - name: Build RAUC Bundle
        run: |
          source poky/oe-init-build-env build
          bitbake «« bundle »»
      - name: Cache Data
        env:
          CACHE_KEY: ${{ secrets.YOCTO_CACHE_KEY }}
        if: ${{ env.CACHE_KEY }}
        run: |
          mkdir -p ~/.ssh
          echo "$CACHE_KEY" >> ~/.ssh/id_ed25519
          chmod 600 ~/.ssh/id_ed25519
          rsync -rvx --ignore-existing build/downloads rauc-community-cache: || true
          rsync -rvx --ignore-existing build/sstate-cache rauc-community-cache: || true
      - name: Show Artifacts
        run: |
          source poky/oe-init-build-env build
          tree --du -h tmp/deploy/images || true
      «% if artifacts %»
      - name: Upload Artifacts
        uses: jluebbe/forrest-upload-artifact@summary
        with:
          path: |
            «% for artifact in artifacts %»
            build/tmp/deploy/images/«« machine »»/«« artifact »»
            «% endfor %»
      «% endif %»
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

default_layers = {
    "poky": {
        "repo": "https://github.com/yoctoproject/poky.git",
        # added by default
        "add": [],
    },
    "meta-rauc": {
        "repo": "https://github.com/rauc/meta-rauc.git",
    },
}

default_context = {
    "release": "master",
    "layers": {
        **default_layers,
    },
    "extra_layers": {},
    "add_layers": [],
    "machine": None,
    "conf": [],
    "image": "core-image-minimal",
    "bundle": "update-bundle",
    "artifacts": []
}

contexts = [
    {
        "layer": "meta-rauc-beaglebone",
        **default_context,
        "release": "scarthgap",
        "machine": "beaglebone-yocto",
        "fstypes": "ext4 wic.zst",
        "wks_file": "beaglebone-yocto-dual.wks.in",
        "conf": [
            'IMAGE_BOOT_FILES:append = " boot.scr"',
        ],
        "artifacts": [
            "core-image-minimal-beaglebone-yocto.rootfs.wic.xz",
            "core-image-minimal-beaglebone-yocto.rootfs.spdx.tar.zst",
            "update-bundle-beaglebone-yocto.raucb",
        ],
    },
    #{
    #    "layer": "meta-rauc-qemux86",
    #    **default_context,
    #    "fstypes": "tar.bz2 wic.zst",
    #    "wks_file": "qemux86-grub-efi.wks",
    #    "conf": [
    #        'EXTRA_IMAGEDEPENDS += "ovmf"',
    #        'PREFERRED_RPROVIDER_virtual-grub-bootconf = "rauc-qemu-grubconf"',
    #    ],
    #    "bundle": "qemu-demo-bundle",
    #    "artifacts": [
    #        "core-image-minimal-qemux86-64.rootfs.wic.zst",
    #    ],
    #},
    {
        "layer": "meta-rauc-raspberrypi",
        **default_context,
        "layers": {
            **default_layers,
            "meta-raspberrypi": {
                "repo": "https://github.com/agherzan/meta-raspberrypi.git",
            },
        },
        "machine": "raspberrypi4",
        "fstypes": "ext4 wic.zst",
        "wks_file": "sdimage-dual-raspberrypi.wks.in",
        "artifacts": [
            "core-image-minimal-raspberrypi4.rootfs.ext4",
            "core-image-minimal-raspberrypi4.rootfs.manifest",
            "core-image-minimal-raspberrypi4.rootfs.spdx.json",
            "core-image-minimal-raspberrypi4.rootfs.testdata.json",
            "update-bundle-raspberrypi4.raucb",
        ],
    },
]

for context in contexts:
    add_layers = context["add_layers"] = []
    for k, v in context["layers"].items():
        sub_layers = v.get("add")
        if sub_layers is None:
            add_layers.append(f"{k}")
        else:
            for add in sub_layers:
                add_layers.append(f"{k}/{add}")

    output = template.render(context)
    file_name = f"{context['layer']}.yml"
    with open(file_name, "w") as file:
        file.write(output)
    print(f"generated {file_name}")
