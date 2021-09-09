SUMMARY = "Date wipe script for factory reset"
DESCRIPTION = ""
LICENSE = "CLOSED"
AUTHOR = "KunYi <kunyi.chen@gmail.com>"
PR = "r1"

RRECOMMENDS_${PN} = "libubootenv"

inherit allarch

SRC_URI = " \
	file://datawipe \
"

do_install () {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/datawipe ${D}/${sbindir}
}
