
SRCBRANCH = "lf-5.10.y"
LOCALVERSION = "-2.0.0"
KERNEL_SRC = "gitsm://source.codeaurora.org/external/imx/linux-imx;protocol=https"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

SRCREV = "ef3f2cfc6010c13feb40cfb7fd7490832cf86f45"

LINUX_VERSION = "5.10.35"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
