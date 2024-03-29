OVERRIDES .= "${@bb.utils.contains('DISTRO_FEATURES', 'rauc', ':rauc-integration', '', d)}"
