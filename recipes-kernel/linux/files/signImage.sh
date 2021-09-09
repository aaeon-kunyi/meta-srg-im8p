#!/bin/bash

set -euo pipefail

# $1 WORKDIR
# $2 CST_DIR
# $3 want signing image
# $4 load address
CSF_SIZE=0x2000
PRINTF=$(which printf)
WORKDIR=$1
CST_DIR=$2
load_addr=$4
padded_file="$3-padded"
signed_file="$3-signed"
image_size="0x`od -t x4 -j 0x10 -N 0x4 --endian=little $3 | head -n1 | awk '{print $2}'`"
align4KB=$(((image_size + 0x1000 - 1) & ~(0x1000 - 1)))
ivt_start=$(((load_addr + align4KB)))
ivt_start=`$PRINTF 0x%x ${ivt_start}`
csf_start=$(((ivt_start + 32))) # ivt_size = 32bytes
csf_start=`$PRINTF 0x%x ${csf_start}`
full_size=$(((align4KB + CSF_SIZE)))
# Gen IVT
sed -e "s/%LOAD_ADDRESS%/$load_addr/g" \
    -e "s/%IVT_START%/$ivt_start/g" \
    -e "s/%CSF_START%/$csf_start/g" \
    ${WORKDIR}/genIVT.tmp > ${WORKDIR}/genIVT.pl

perl ${WORKDIR}/genIVT.pl

# padding image
echo "will padding file to ${align4KB}, for align 4KB boundary"
objcopy -I binary -O binary --pad-to=${align4KB} --gap-fill=0x00 $3 $padded_file
cat $padded_file ivt.bin > $signed_file
image_size=`$PRINTF 0x%x $(stat -L -c %s $signed_file)`

# gen csf-image.txt for cst tool
sed -e "s,%CST_DIR%,${CST_DIR},g" \
    -e "s,%LOAD_ADDR%,${load_addr},g" \
    -e "s,%IMAGE_SIZE%,${image_size},g" \
    -e "s,%IMAGE_NAME%,${signed_file},g" \
    ${WORKDIR}/csf-image.tmp > ${WORKDIR}/csf-image.txt

$CST_DIR/linux64/bin/cst  -i ${WORKDIR}/csf-image.txt -o ${WORKDIR}/csf-image.bin
cat ${WORKDIR}/csf-image.bin >> $signed_file
echo "will padding file to $full_size, for add CSF size(${CSF_SIZE})"
objcopy -I binary -O binary --pad-to=$full_size --gap-fill=0x00 $signed_file $signed_file
