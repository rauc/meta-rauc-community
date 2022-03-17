IMAGE_INSTALL:append = " kernel-image kernel-modules"

IMAGE_FSTYPES += "wic"
WKS_FILE = "qemux86-grub-efi.wks"
do_image_wic[depends] += "boot-image:do_deploy"
