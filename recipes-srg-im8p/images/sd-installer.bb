require recipes-core/images/core-image-minimal.bb

DESCRIPTION = "SD Card installer image"
LICENSE="MIT"

INSTALLED_IMAGE ??= "srg-im8p-image"
IMAGE_SUFFIX ??= "wic.gz"

SOC_DEFAULT_WKS_FILE_mx8mp = "sd-installer.wks.in"

IMAGE_FEATURES_append += "read-only-rootfs"

IMAGE_INSTALL_append = " \
  bmap-tools \
  bash \
  util-linux \
  coreutils \
  dosfstools \
  mmc-utils \
  xz \
  gzip \
  bzip2 \
  lzop \
  lzo \
  lz4 \
  tar \
  parted \
  e2fsprogs \
  e2fsprogs-mke2fs \
  e2fsprogs-e2fsck \
  e2fsprogs-resize2fs \
  gptfdisk \
  whiptail \
"

add_boot_files() {
	echo "add boot files"
  install -m 644 "${DEPLOY_DIR_IMAGE}/srg-im8p.dtb" "${IMAGE_ROOTFS}/boot/srg-im8p.dtb"
	install -m 644 "${DEPLOY_DIR_IMAGE}/initrd-installer-${MACHINE}.img" "${IMAGE_ROOTFS}/boot/initrd.img"
}

add_installed_files() {
	echo "add installed files"
  install -d  ${IMAGE_ROOTFS}/opt/img
	install -m 644 "${DEPLOY_DIR_IMAGE}/${INSTALLED_IMAGE}-${MACHINE}.wic.bmap" "${IMAGE_ROOTFS}/opt/img/${INSTALLED_IMAGE}.wic.bmap"
	install -m 644 "${DEPLOY_DIR_IMAGE}/${INSTALLED_IMAGE}-${MACHINE}.${IMAGE_SUFFIX}" "${IMAGE_ROOTFS}/opt/img/${INSTALLED_IMAGE}.${IMAGE_SUFFIX}"
  install -m 644 "${DEPLOY_DIR_IMAGE}/imx-boot" "${IMAGE_ROOTFS}/opt/img"

  # for install emmc_install.sh into rootfs
  echo "#!/bin/bash\n\
\n\
# Enable strict shell mode\n\
set -euo pipefail\n\
\n\
EMMC_DEV=\"mmcblk2\"\n\
WIC_IMAGE=\"/opt/img/${INSTALLED_IMAGE}.${IMAGE_SUFFIX}\"\n\
\n\
# flash OS image into EMMC\n\
echo \"=================================\"\n\
echo \"= will flash OS image into EMMC =\"\n\
echo \"=================================\"\n\
bmaptool copy \$WIC_IMAGE /dev/\$EMMC_DEV\n\
\n\
# resize for data partition\n\
echo \"===================================\"\n\
echo \"= adjust gpt table/partition size =\"\n\
echo \"===================================\"\n\
sgdisk -e /dev/\$EMMC_DEV       # fixed gpt tabel\n\
parted -s /dev/\$EMMC_DEV resizepart 3 100%\n\
resize2fs /dev/\${EMMC_DEV}p3   # resize filesystem\n\
\n\
# flash bootloader into EMMC boot0 partition\n\
echo \"===================================\"\n\
echo \"= will flash bootloader into EMMC =\"\n\
echo \"===================================\"\n\
echo \"writing primary bootloader ...\"\n\
echo 0 > \"/sys/block/\${EMMC_DEV}boot0/force_ro\"    #  disable readonly\n\
dd if=/opt/img/imx-boot of=/dev/\${EMMC_DEV}boot0 bs=4K conv=fsync && sync  #  flash image into boot0 partitions\n\
mmc bootpart enable 1 0 /dev/\$EMMC_DEV               #  enable boot from boot0 partitions\n\
echo 1 > \"/sys/block/\${EMMC_DEV}boot0/force_ro\" #  enable readonly\n\
echo \"writing alternate bootloader ...\"\n\
echo 0 > \"/sys/block/\${EMMC_DEV}boot1/force_ro\"    #  disable readonly\n\
dd if=/opt/img/imx-boot of=/dev/\${EMMC_DEV}boot1 bs=4K conv=fsync && sync  #  flash image into boot0 partitions\n\
#\n\
#mmc bootpart enable 1 1 /dev/\$EMMC_DEV               #  enable boot from boot1 partitions\n\
#\n\
echo 1 > \"/sys/block/\${EMMC_DEV}boot1/force_ro\" #  enable readonly\n\
\n\
echo \"===========================\"\n\
echo \"=  complete flash EMMC    =\"\n\
echo \"===========================\"\n\
poweroff\n\
" > "${WORKDIR}/emmc_install.sh"

	install -m 0755 "${WORKDIR}/emmc_install.sh" "${IMAGE_ROOTFS}/usr/sbin"
}

ROOTFS_POSTPROCESS_COMMAND += " add_boot_files; add_installed_files;"
