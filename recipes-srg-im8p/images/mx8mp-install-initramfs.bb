DESCRIPTION = "Small image capable for installer image"
LICENSE = "MIT"

PACKAGE_INSTALL = " initramfs-installer \
		${VIRTUAL-RUNTIME_base-utils} \
		udev \
    		base-files \
    		base-passwd \
    		busybox \
		e2fsprogs-mke2fs \
    		e2fsprogs-e2fsck \
		${ROOTFS_BOOTSTRAP_INSTALL} \
		"
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

export IMAGE_BASENAME = "mx8mp-install-initramfs"
inherit core-image

DEPENDS_append += " u-boot-tools-native"

do_uboot_initrd() {
	cd ${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/
	uboot-mkimage -A ${UBOOT_ARCH} -O linux -T ramdisk -C gzip -n "initial ramdisk" \
	-d ${IMAGE_BASENAME}-${MACHINE}.${INITRAMFS_FSTYPES} \
	initrd-installer-${MACHINE}.img
}

do_deploy_append() {
	install -m 0644 ${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/initrd-installer-${MACHINE}.img \
		${{DEPLOY_DIR_IMAGE}}/initrd-installer-${MACHINE}.img
}

IMAGE_POSTPROCESS_COMMAND_append += "do_uboot_initrd;"
