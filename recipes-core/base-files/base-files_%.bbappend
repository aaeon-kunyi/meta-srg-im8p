
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_install_basefilesissue () {
	install -m 644 ${WORKDIR}/issue*  ${D}${sysconfdir}
	# date=$(date '+%Y.%m')
}
