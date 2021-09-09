DESCRIPTION = "generation swupdate update image(.swu)"
SECTION = ""
LICENSE="CLOSED"

DEPENDS += "srg-im8p-image swupdate"

SRC_URI = " \
    file://sw-description \
"

# images to build before building adu update image
IMAGE_DEPENDS = "srg-im8p-image"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = " \
        srg-im8p-image \
        "
IMAGE_FEATURES += "lua"

SWUPDATE_IMAGES_FSTYPES[srg-im8p-image] = ".ext4.zst"

RFS_VERSION ?= "1.0.1"
SWU_PRIVATE_KEY ?= "${TOPDIR}/../swu-keys/priv.pem"
SWU_PRIVATE_KEY_PASSWORD ?= "${TOPDIR}/../swu-keys/passout"
SWU_SOFTWARE_VERSION ??= "1.0.0"

python () {
    # detect in docker
    if os.path.exists("/.dockerenv"):
        d.setVar("SWUPDATE_PRIVATE_KEY", d.getVar("SWU_PRIVATE_KEY").replace("build/..", "repo"))
        d.setVar("SWUPDATE_PASSWORD_FILE", d.getVar("SWU_PRIVATE_KEY_PASSWORD").replace("build/..", "repo"))
}
#################################################
# Generated RSA key with password using command:
#################################################
# -- for generation prive key --
# openssl genrsa -aes256 -passout file:priv.pass -out priv.pem
#
# -- for generation public key --
# openssl rsa -in priv.pem -passin file:priv.pass -out public.pem -outform PEM -pubout
#
SWUPDATE_SIGNING = "RSA"
SWUPDATE_PRIVATE_KEY = "${SWU_PRIVATE_KEY}"
SWUPDATE_PASSWORD_FILE = "${SWU_PRIVATE_KEY_PASSWORD}"

inherit swupdate
