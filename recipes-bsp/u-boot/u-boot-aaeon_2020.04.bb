# Copyright 2017-2021 NXP
# Copyright 2021 Sparktech/UWINGS
require recipes-bsp/u-boot/u-boot.inc
require recipes-bsp/u-boot/u-boot-imx-common.inc

PROVIDES += "u-boot"
DESCRIPTION = "i.MX U-Boot suppporting SRG-IM8P boards."
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

UBOOT_SRC = "gitsm://source.codeaurora.org/external/imx/uboot-imx;protocol=https"
SRCBRANCH = "lf_v2020.04"
SRCREV = "ad7b74b415ab5e38dd4ebf935dad1cee3fec4742"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH} \
	file://fw_env.config \
	file://0001-add-support-SRG-IM8P-Board.patch \
"
inherit kernel-arch uboot-extlinux-config

do_configure_prepend_mx8mp() {
    # check secure boot is enabled to apply CONFIG_IMX_HAB on configure file
    if [ "x${ENABLED_SECURE_BOOT}" = "xyes" ]; then
        if [ -n "${UBOOT_CONFIG}" ]; then
            unset i j
            for config in ${UBOOT_MACHINE}; do
                i=$(expr $i + 1);
                for type in ${UBOOT_CONFIG}; do
                    j=$(expr $j + 1);
                    if [ $j -eq $i ]; then
                        echo "CONFIG_IMX_HAB=y" >> ${S}/configs/${config}
                    fi
                done
                unset  j
            done
            unset  i
        fi
    fi
}

do_install_append_mx8mp () {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
    #
    install -d ${D}/boot/extlinux
    install -m 0644 ${B}/extlinux.conf ${D}/boot/extlinux/extlinux.conf
}

do_deploy_append_mx8m() {
    # Deploy the mkimage, u-boot-nodtb.bin and fsl-imx8m*-XX.dtb for mkimage to generate boot binary
    if [ -n "${UBOOT_CONFIG}" ]; then
        unset i j
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]; then
                    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/arch/arm/dts/${UBOOT_DTB_NAME}  ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/u-boot-nodtb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG}
                fi
            done
            unset  j
        done
        unset  i
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx8)"
