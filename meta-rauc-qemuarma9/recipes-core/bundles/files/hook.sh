#!/bin/sh

case "$1" in
        slot-post-install)
                # only rootfs needs to be handled
                test "$RAUC_SLOT_CLASS" = "rootfs" || exit 0

                touch "$RAUC_SLOT_MOUNT_POINT/extra-file"
                ;;
        *)
                exit 1
                ;;
esac

exit 0