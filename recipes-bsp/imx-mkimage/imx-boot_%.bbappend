
FILESEXTRAPATHS_append := "${THISDIR}/habsign"

SRC_URI_append += " \
    file://csf-spl.tmp \
    file://csf-fit.tmp \
    file://patch.sh \
"
python () {
    if d.getVar('ENABLED_SECURE_BOOT', False) == 'yes':
        # detect in docker
        if os.path.exists('/.dockerenv'):
            d.setVar('CST_DIR', d.getVar('CST_DIR').replace('build/..', 'repo'))
}

do_deploy_append() {
    if [ ! "x${ENABLED_SECURE_BOOT}" = "xyes" ]; then
	echo "no secure boot"
	exit 0
    fi

    bbnote "enabled secure boot feature, to run signtool"
    if [ ! -d ${CST_DIR} ] && [ ! -e ${CST_DIR}/linux64/bin/cst ]; then
	echo "install IMX Code Sign Tool first, please!"
	exit 1
    fi

    # for loader image
    LOADER_HEADER=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep header_image_off | cut -f 2)
    IMAGE_OFFSET=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep "^ image_off" | cut -f 3)
    SPL_CSF_OFFSET=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep "^ csf_off" | cut -f 3)
    SPL_HAB_BLOCK=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep "spl hab block:" | cut -f 2)
    # for secondary bootloader image
    SLD_HEADER=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep sld_header_off | cut -f 2)
    SLD_CSF_OFFSET=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep sld_csf_off | cut -f 3)
    SLD_HAB_BLOCK=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot.log | grep "sld hab block:" | cut -f 2)
    FIT_BLOCK=$(cat ${DEPLOYDIR}/${BOOT_TOOLS}/imx-boot-fit-hab.log | tail -n 4 | grep -v "^TEE_LOAD")

    for target in ${IMXBOOT_TARGETS}; do
        # Use first "target" as IMAGE_IMXBOOT_TARGET
        if [ "$IMAGE_IMXBOOT_TARGET" = "" ]; then
            IMAGE_IMXBOOT_TARGET="$target"
            echo "Set boot target as $IMAGE_IMXBOOT_TARGET"
        fi
    done

    FLASH_BIN="${DEPLOYDIR}/${BOOT_CONFIG_MACHINE}-${IMAGE_IMXBOOT_TARGET}"
    # fix up csf-spl.txt
    sed -e "s,%SPL_HAB_BLOCK%,${SPL_HAB_BLOCK},g" \
    -e "s,%CST_DIR%,${CST_DIR},g" \
    -e "s,%FLASH_BIN%,${FLASH_BIN},g" \
    ${WORKDIR}/csf-spl.tmp > ${WORKDIR}/csf-spl.txt
    ${CST_DIR}/linux64/bin/cst -i ${WORKDIR}/csf-spl.txt -o ${WORKDIR}/csf-spl.bin

    # fix up csf-fit.txt
    sed -e "s,%CST_DIR%,${CST_DIR},g" \
    ${WORKDIR}/csf-fit.tmp > ${WORKDIR}/csf-fit.txt
    # fill block information for Authentication
    IFS='\n'
    echo $FIT_BLOCK | while read -r block;
    do
        echo "    $block \"$FLASH_BIN\", \\" >> ${WORKDIR}/csf-fit.txt
    done
    echo "    ${SLD_HAB_BLOCK} \"${FLASH_BIN}\"" >> ${WORKDIR}/csf-fit.txt
    ${CST_DIR}/linux64/bin/cst -i ${WORKDIR}/csf-fit.txt -o ${WORKDIR}/csf-fit.bin

    # patch bootloader image for signed
    BLDRNAME=$(echo ${BOOT_CONFIG_MACHINE}-${IMAGE_IMXBOOT_TARGET})
    bbnote "patch bootloader image for signed: $BLDRNAME"
    install -m 0644 "${S}/${BLDRNAME}"  "${S}/${BLDRNAME}-signed"
    bash ${WORKDIR}/patch.sh "${WORKDIR}/csf-spl.bin" "${S}/${BLDRNAME}-signed" $SPL_CSF_OFFSET
    bash ${WORKDIR}/patch.sh "${WORKDIR}/csf-fit.bin" "${S}/${BLDRNAME}-signed" $SLD_CSF_OFFSET
    #dd if="${WORKDIR}/csf-spl.bin" of="${S}/${BLDRNAME}-signed" seek="$SPL_CSF_OFFSET" bs=1 conv=notrunc
    #dd if="${WORKDIR}/csf-fit.bin" of="${S}/${BLDRNAME}-signed" seek="$SLD_CSF_OFFSET" bs=1 conv=notrunc
    install -m 0644 "${S}/${BLDRNAME}-signed" ${DEPLOYDIR}

    # copy csf.txt and binaries file to deploy
    bbnote copy csf files of HAB to deploy
    install -m 0644 ${WORKDIR}/csf-spl.txt                 ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${WORKDIR}/csf-spl.bin                 ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${WORKDIR}/csf-fit.txt                 ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0644 ${WORKDIR}/csf-fit.bin                 ${DEPLOYDIR}/${BOOT_TOOLS}

    cd ${DEPLOYDIR}
    [ -L $BOOT_NAME] && rm ${BOOT_NAME}
    ln -sf "${BLDRNAME}-signed" ${BOOT_NAME}
    cd -

}
