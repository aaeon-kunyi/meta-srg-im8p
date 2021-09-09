

do_install_append() {
	install -d ${D}${sysconfdir}/udev/mount.blacklist.d
	echo "/dev/mmcblk2" > ${WORKDIR}/emmc.blackist
	install -m 0644 ${WORKDIR}/emmc.blackist ${D}${sysconfdir}/udev/mount.blacklist.d
}
