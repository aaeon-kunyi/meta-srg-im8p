
# installl kernel header files into rootfs
IMAGE_INSTALL_append += "kernel-devsrc"
# install device-init
IMAGE_INSTALL_append += "device-init"
# install datawipe
IMAGE_INSTALL_append += "datawipe"

# install swupdate
IMAGE_INSTALL_append += "swupdate swupdate-www swupdate-tools libubootenv-bin"

add_boot_files() {
	echo "add boot files"
	if [ "x${INITRAMFS_IMAGE_BUNDLE}" != "x" ]; then
		install -m 644 "${DEPLOY_DIR_IMAGE}/fitImage-${INITRAMFS_IMAGE_NAME}-${KERNEL_FIT_LINK_NAME}" "${IMAGE_ROOTFS}/boot/fitImage-initramfs.bin"
	fi
	install -m 0644 "${DEPLOY_DIR_IMAGE}/srg-im8p.dtb" "${IMAGE_ROOTFS}/boot/srg-im8p.dtb"
	install -m 0644 "${DEPLOY_DIR_IMAGE}/initrd-srg-im8p.img" "${IMAGE_ROOTFS}/boot/initrd.img"
}

ROOTFS_POSTPROCESS_COMMAND += "add_boot_files;"
