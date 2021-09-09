SUMMARY = "Read only rootfs with overlay init script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
SRC_URI = "file://init-installer.sh"
PR = "r0"

DEPANDS = "u-boot-tools-native"

S = "${WORKDIR}"

do_install() {
        install -m 0755 ${WORKDIR}/init-installer.sh ${D}/init

        install -d ${D}/dev
        install -d "${D}/mnt/root"
        install -d "${D}/data"
        mknod -m 622 ${D}/dev/console c 5 1
}

do_deploy_append() {
        u-boot-mkimage -A arm64
}

# Due to kernel dependency
PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN} += " /init /mnt/root /data /dev"
FILES_${PN} += "/dev"

