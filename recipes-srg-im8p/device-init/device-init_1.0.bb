SUMMARY = "generic device init script"
DESCRIPTION = "for device generic initilization"
LICENSE = "CLOSED"
AUTHOR = "KunYi <kunyi.chen@gmail.com>"
PR = "r1"

RRECOMMENDS_${PN} = "libubootenv"

SRC_URI = " \
	file://device-init.sh \
	file://device-init.service \
	"

do_install () {
    install -d ${D}/${sbindir}
    install -m 0755 ${WORKDIR}/*.sh ${D}/${sbindir}

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/device-init.service ${D}${systemd_unitdir}/system
}

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "device-init.service"

inherit allarch systemd
