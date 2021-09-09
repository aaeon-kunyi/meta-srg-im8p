DESCRIPTION = "Small image capable of mounting an overlayfs on top of a ready-only root-filesystem."
LICENSE = "MIT"

PACKAGE_INSTALL = "initramfs-ro-rootfs-overlay \
		${VIRTUAL-RUNTIME_base-utils} \
		udev \
    		base-files \
    		base-passwd \
    		busybox \
		e2fsprogs-mke2fs \
    		e2fsprogs-e2fsck \
		kernel-module-overlay \
		kernel-module-squashfs \
		kernel-module-imx-sdma \
		firmware-imx-sdma \
		${ROOTFS_BOOTSTRAP_INSTALL} \
		"
KERNEL_MODULE_AUTOLOAD = "overlay squashfs imx-sdma"

# Avoid installation of syslog
NO_RECOMMENDATIONS += "busybox-syslog"
# Avoid static /dev
USE_DEVFS = "1"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = "read-only-rootfs"
IMAGE_INSTALL = ""
IMAGE_LINGUAS = ""

# Avoid dependency loops
EXTRA_IMAGEDEPENDS = ""
KERNELDEPMODDEPEND = ""

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_FSTYPES_imx8mp = " ${INITRAMFS_FSTYPES}"
IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

export IMAGE_BASENAME = "mx8mp-initramfs"
inherit core-image

DEPENDS_append += " u-boot-tools-native"

do_uboot_initrd() {
	cd ${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete
	uboot-mkimage -A ${UBOOT_ARCH} -O linux -T ramdisk -C gzip -n "initial ramdisk" \
	-d ${IMAGE_BASENAME}-${MACHINE}.${INITRAMFS_FSTYPES} \
	initrd-${MACHINE}.img
}

do_deploy_append() {
	install -m 0644 ${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/initrd-${MACHINE}.img \
		${{DEPLOY_DIR_IMAGE}}/initrd-${MACHINE}.img
}

IMAGE_POSTPROCESS_COMMAND_append += "do_uboot_initrd;"
