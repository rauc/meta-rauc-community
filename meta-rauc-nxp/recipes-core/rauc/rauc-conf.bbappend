do_install:prepend() {
	sed -i "s/@@MACHINE@@/${MACHINE}/g" ${S}/system.conf
}
