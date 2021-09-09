# Copyright 2017-2021 NXP
# Copyright 2021 Sparktech/UWings
require recipes-bsp/u-boot/u-boot.inc

HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
DESCRIPTION = "i.MX U-Boot suppporting SRG-IM8P boards."
SECTION = "bootloaders"
DEPENDS += "flex-native bison-native dtc-native"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"
PE = "1"

PROVIDES += "u-boot"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
UBOOT_SRC = "gitsm://source.codeaurora.org/external/imx/uboot-imx;protocol=https"
SRCBRANCH = "lf_v2021.04"
SRCREV = "3463140881c523e248d2fcb6bfc9ed25c0db93bd"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH} \
	file://0001-LFU-188-1-imx8m-soc-Relocate-u-boot-to-the-top-DDR-i.patch \
	file://0002-LFU-188-2-imx8mp_evk-Remove-reservation-for-MCU-RPMS.patch \
	file://0003-LFU-193-1-clk-imx8mp-Update-clock-tree-for-USB-relev.patch \
	file://0004-LFU-193-2-usb-xhci-imx8m-Update-iMX8MP-XHCI-driver-t.patch \
	file://0005-LFU-193-3-DTS-imx8mp-evk-Sync-the-USB-nodes-with-ker.patch \
	file://0006-LFU-193-4-imx8mp_evk-Remove-USB2-PWR-GPIO-control.patch \
	file://0007-LFU-193-5-DTS-imx8mp-Add-the-CMA-reserved-memory.patch \
	file://0008-LF-3892-1-imx8mq_evk-support-SR-IR.patch \
	file://0009-LF-3892-2-imx8mp_evk-enable-usb-power-by-default.patch \
	file://0010-LF-3892-3-imx8mp-disable-snvs-and-sdma.patch \
	file://0011-LF-3892-4-imx8mn-sync-dts-usb-with-nxp-kernel.patch \
	file://0012-LF-3892-5-imx8mn_evk-update-defconfig-and-code-for-S.patch \
	file://0013-LF-3892-6-imx8mp_evk-update-defconfig-and-code-for-S.patch \
	file://0014-LF-4182-imx8m-enable-CONFIG_CMD_POWEROFF.patch \
	file://0015-LFU-198-imx8mq_evk-Increase-malloc-size-to-32MB.patch \
	file://0016-LF-4200-imx8m-soc-drop-phy-reset-gpios-for-fec.patch \
	file://0017-LF-4276-arm-dts-imx8mq-add-the-dwc3-fallback-compati.patch \
	file://0018-LF-4277-arm-dts-imx8mn-correct-spba-bus-name.patch \
	file://0019-board-add-support-srg-im8p.patch \
	file://fw_env.config \
"

S = "${WORKDIR}/git"

inherit fsl-u-boot-localversion

LOCALVERSION ?= "-5.10.35-2.0.0"
BOOT_TOOLS = "imx-boot-tools"

do_install_append_mx8mp () {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

do_deploy_append_mx8m() {
    # Deploy the mkimage, u-boot-nodtb.bin and fsl-imx8m*-XX.dtb for mkimage to generate boot binary
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/arch/arm/dts/${UBOOT_DTB_NAME}  ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/u-boot-nodtb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${type}
                fi
            done
            unset  j
        done
        unset  i
    fi
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx8)"
UBOOT_NAME_mx8 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
