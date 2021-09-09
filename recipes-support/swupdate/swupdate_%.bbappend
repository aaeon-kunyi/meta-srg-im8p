# for override original defconfig

FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

PACKAGECONFIG_CONFARGS = ""

SRCREV = "c4ff683594250f2bd2889831ebcdb16e9d50383a"
SRC_URI += " \
     file://swupdate.cfg \
     file://09-swupdate-args \
     file://sw-versions.tmpl \
     "
SWU_HW_COMPAT ?= "${MODEL_NAME} ${HW_REV}"
SWU_PUBLIC_KEY ?= "${TOPDIR}/../swu-keys/public.pem"
wwwdir = "${libdir}/swupdate/web"

DEPENDS_append += " curl json-c"

python () {
    # detect in docker
    if os.path.exists("/.dockerenv"):
        d.setVar("SWU_PUBLIC_KEY", d.getVar("SWU_PUBLIC_KEY").replace("build/..", "repo"))
}

do_compile_append() {
    echo "${SWU_HW_COMPAT}" > ${WORKDIR}/swupdate-hw-compat
    sed -e "s,%rfs_ver%,${RFS_VERSION},g" \
        ${WORKDIR}/sw-versions.tmpl > ${WORKDIR}/sw-versions
}

do_install_append() {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/swupdate-hw-compat ${D}${sysconfdir}/swupdate-hw-compat
    install -m 644 ${WORKDIR}/sw-versions       ${D}${sysconfdir}/sw-versions

    install -d ${D}${sysconfdir}/swupdate/
    install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}/swupdate/swupdate.cfg
    install -m 644 ${SWU_PUBLIC_KEY} ${D}${sysconfdir}/swupdate/public.pem

    install -d ${D}${libdir}/swupdate/conf.d
    echo "SWUPDATE_ARGS=\"\$SWUPDATE_ARGS -p reboot -k ${sysconfdir}/swupdate/public.pem\"" > ${D}${libdir}/swupdate/conf.d/swupdate.env
    #echo "SWUPDATE_WEBSERVER_ARGS=\"\"" >> ${D}${libdir}/swupdate/conf.d/swupdate.env
    install -m 644 ${WORKDIR}/09-swupdate-args ${D}${libdir}/swupdate/conf.d/09-swupdate-args
}

FILES_${PN} += "${sysconfdir}/swupdate/public.pem"
FILES_${PN} += "${sysconfdir}/swupdate/swupdate.cfg"
