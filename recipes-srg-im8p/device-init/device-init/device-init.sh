
#!/bin/sh

# Enable strict shell mode
set -euo pipefail

FW_PRINTENV="/usr/bin/fw_printenv"
FW_SETENV="/usr/bin/fw_setenv"
FW_ENVFILE="/etc/fw_env.config"
HWCLOCK2SYS="/sbin/hwclock --hctosys --utc --noadjfile"

# for auto change store place for u-boot environment variables
check_fwenv_file() {
	rootfs_dev=$(cat /proc/cmdline  | cut -d' ' -f 2 | cut -d= -f 2 | cut -dp -f 1)
	if [ "${rootfs_dev}" == "/dev/mmcblk1" ]; then
		# for sd card booting, default setting for emmc
		# /dev/mmcblk1 for sdcard
		# /dev/mmcblk2 for emmc
		sed -i "s/mmcblk2/mmcblk1/g" $FW_ENVFILE
		logger "env. on sdcard"
	fi
}

clear_datawipe_variable() {
	check=$($FW_PRINTENV datawipe)
	if [ "x$check" != "xdatawipe=" ]; then
		$FW_SETENV datawipe
		logger "clear datawipe variable"
	fi
}

if [ ! -e /etc/device-init ]; then
	[ ! -e /etc/u-boot-initial-env ] && ln -ns /etc/u-boot-aaeon-initial-env /etc/u-boot-initial-env
	logger "create device-init for finish"
	clear_datawipe_variable
	touch /etc/device-init

fi

$HWCLOCK2SYS

exit 0
