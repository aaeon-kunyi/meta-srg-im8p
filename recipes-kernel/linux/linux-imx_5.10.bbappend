
SUMMARY = "Linux Kernel provided and supported by Sparktech/UWINGS"
DESCRIPTION = "Linux Kernel provided and supported by Sparktech/UWINGS with focus on \
AAEON IoT Gateway"

require linux-imx-common.inc

DELTA_KERNEL_DEFCONFIG = "custom.cfg"

SRC_URI_append += " \
    file://0001-add-device-tree-file-for-support-srg-im8p-of-aaeon.patch \
    file://custom.cfg \
    file://genIVT.tmp \
    file://csf-image.tmp \
    file://signImage.sh \
"


python () {
    if d.getVar('ENABLED_SECURE_BOOT', False) == 'yes':
        # detect in docker
        if os.path.exists('/.dockerenv'):
            d.setVar('CST_DIR', d.getVar('CST_DIR').replace('build/..', 'repo'))
}

do_signimage() {
    if [ ! "x${ENABLED_SECURE_BOOT}" = "xyes" ]; then
	echo "no secure boot"
	exit 0
    fi

    bbnote "enabled secure boot feature, to run signtool"
    if [ ! -d ${CST_DIR} ] && [ ! -e ${CST_DIR}/linux64/bin/cst ]; then
	echo "install IMX Code Sign Tool first, please!"
	exit 1
    fi

    echo "singing kernel image"
    install -m 0644 "${B}/arch/${ARCH}/boot/Image" "${B}/arch/${ARCH}/boot/Image_unsigned"
    bash "${WORKDIR}/signImage.sh" "${WORKDIR}" "${CST_DIR}" "${B}/arch/${ARCH}/boot/Image" "${KERNEL_LOADADDR}"
    # install -m 0644 ${B}/arch/${ARCH}/boot/Image-signed "$deployDir/Image-signed.bin"
    install -m 0644 "${B}/arch/${ARCH}/boot/Image-signed" "${B}/arch/${ARCH}/boot/Image"
}

addtask do_signimage before do_install after do_strip
