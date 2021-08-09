#!/bin/bash

set -euo pipefail # for strict mode

##########################################################################
OPENSSL=$(which openssl)
[ -z $OPENSSL ] && echo "please intall openssl package first." && exit 0
##########################################################################

if [ -d swu-keys ]; then
   echo "swupdate signing key folder exist"
   echo "if you want re-initionlization please backup and remove first."
   exit 0
fi

##########################################################################
SWU_PASSOUT="DGkHyTPqo9^OfH)("
echo "####################################################################"
echo "create RSA key pairs for swupdate"
echo "####################################################################"
mkdir -p ./swu-keys
odir=$PWD
pushd ./swu-keys
echo $SWU_PASSOUT > passout
echo "generation RSA private key for swupdate"
openssl genrsa -aes256 -passout file:passout -out priv.pem
echo "generation RSA public key for swupdate"
openssl rsa -in priv.pem -passin file:passout -out public.pem -outform PEM -pubout
popd
echo "####################################################################"
echo "finish create RSA key pairs for swupdate"
echo "####################################################################"
##########################################################################
##########################################################################
##########################################################################
CST_TARFILE="./tools/cst-3.3.1.tgz"
DEF_SERIAL_NUMBER="41325426"
DEF_KEY_PASS="KeyKunYi4SecureBoot"
# const variables
CERTS="./SRK1_sha256_4096_65537_v3_ca_crt.pem,\
./SRK2_sha256_4096_65537_v3_ca_crt.pem,\
./SRK3_sha256_4096_65537_v3_ca_crt.pem,\
./SRK4_sha256_4096_65537_v3_ca_crt.pem\
"
##########################################################################

if [ -d cst ] || [ -d cst-3.3.1 ]; then
	echo "'cst' or 'cst-3.3.1' folder exist"
	echo "if you want re-initionlization please backup and remove first."
	exit 0
fi

if [ ! -f $CST_TARFILE ]; then
	echo "not found $CST_TARFILE, please download from NXP website(registration required)"
	echo "download url:https://www.nxp.com/webapp/Download?colCode=IMX_CST_TOOL_NEW"
	exit 1
fi
##########################################################################
echo "####################################################################"
echo "create PKI tree for secure boot"
echo "####################################################################"
tar xzf $CST_TARFILE
odir=$PWD
pushd cst-3.3.1/keys
echo $DEF_SERIAL_NUMBER > serial  # for OpenSSL use on cerficate serial number
echo $DEF_KEY_PASS > key_pass.txt
echo $DEF_KEY_PASS >> key_pass.txt
./hab4_pki_tree.sh -existing-ca n  -use-ecc n -kl 4096 -duration 20 -num-srk 4 -srk-ca y
cd ../crts
../linux64/bin/srktool --hab 4 \
	--table SRK_1_2_3_4_table.bin \
	--efuses SRK_1_2_3_4_fuse.bin \
	--digest sha256 \
	--certs $CERTS \
	--fuse_format 1 2>&1 | tee $odir/hab_fuse.txt
popd
mv cst-3.3.1 cst
echo "####################################################################"
echo "finish make signing key pairs for swupdate & cst"
echo "####################################################################"

