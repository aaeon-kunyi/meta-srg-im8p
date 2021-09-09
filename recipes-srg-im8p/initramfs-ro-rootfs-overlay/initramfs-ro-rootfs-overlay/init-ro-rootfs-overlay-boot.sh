#!/bin/sh

# Enable strict shell mode
set -euo pipefail

PATH=/sbin:/bin:/usr/sbin:/usr/bin

MOUNT="/bin/mount"
UMOUNT="/bin/umount"
INIT="/sbin/init"
EXT4FMT="/sbin/mkfs.ext4"
FSCKEXT4="/sbin/fsck.ext4"
FSCK_ARGS="-f -p"

ROOT_MOUNT="/mnt/rootrw"

ROOT_RODEVICE=""
ROOT_ROMOUNT="/mnt/root"

# for squashfs
# ROOT_ROFSTYPE="squashfs"
# ROOT_ROMOUNTOPTIONS_DEVICE=""

# for ext4
ROOT_ROFSTYPE="ext4"
ROOT_ROMOUNTOPTIONS_DEVICE="ro,noatime,nodiratime"

# default for (emmc)
ROOT_RWDEVICE="/dev/mmcblk2p3"
ROOT_RWFSTYPE="ext4"
ROOT_RWMOUNT="/data"
ROOT_RWMOUNTOPTIONS_DEVICE="rw,noatime"
DATA_WIPE=""
EXIT_CODE=0

early_setup() {
	mkdir -p /proc
	mkdir -p /sys
	$MOUNT -t proc proc /proc
	$MOUNT -t sysfs sysfs /sys
	grep -w "/dev" /proc/mounts >/dev/null || $MOUNT -t devtmpfs none /dev
	modprobe overlay
	modprobe squashfs
	modprobe imx-sdma
}

read_args() {
	[ -z "${CMDLINE+x}" ] && CMDLINE=`cat /proc/cmdline`
	for arg in $CMDLINE; do
		# Set optarg to option parameter, and '' if no parameter was
		# given
		optarg=`expr "x$arg" : 'x[^=]*=\(.*\)' || echo ''`
		case $arg in
			root=*)
				ROOT_RODEVICE=$optarg
				if [ "${ROOT_RODEVICE}" == "/dev/mmcblk2p1" ] || [ "${ROOT_RODEVICE}" == "/dev/mmcblk2p2" ]; then
					ROOT_RWDEVICE="/dev/mmcblk2p3" 	# for emmc
				elif [ "${ROOT_RODEVICE}" == "/dev/mmcblk1p1" ] || [ "${ROOT_RODEVICE}" == "/dev/mmcblk1p2" ]; then
					ROOT_RWDEVICE="/dev/mmcblk1p3"  # for sdhc
				fi
				;;
			rootfstype=*)
				ROOT_ROFSTYPE="$optarg" ;;
			rootrw=*)
				ROOT_RWDEVICE=$optarg ;;
			rootrwfstype=*)
				ROOT_RWFSTYPE="$optarg" ;;
			rootrwoptions=*)
				ROOT_RWMOUNTOPTIONS_DEVICE="$optarg" ;;
			init=*)
				INIT=$optarg ;;
			datawipe)
				DATA_WIPE="1" ;;
		esac
	done
}

fatal() {
	echo "initramfs: $1" >$CONSOLE
	echo >$CONSOLE
	exec sh
}

log() {
	echo "initramfs: $1" >$CONSOLE
}

#wait_for_device() {
#	while [ ! -b $ROOT_RWDEVICE ]; do
#		sleep 1
#		log "waiting for $ROOT_RWDEVICE"
#	done
#}

wait_for_device() {
	count=0
	while [ ! -b $ROOT_RWDEVICE ]; do
		sleep 1
		log "waiting for $ROOT_RWDEVICE"
		count='expr $count + 1'
		[[ "$count" -gt 10 ]] && fatal "Failed:waiting too long:$ROOT_RWDEVICE";
	done
}

check_factory_reset() {
	if [ "x$DATA_WIPE" = "x1" ]; then
		log "wipe data partition for factory reset"
		$EXT4FMT -F $ROOT_RWDEVICE
	fi
}

early_setup

[ -z "${CONSOLE+x}" ] && CONSOLE="/dev/console"

read_args

check_datapartition() {
	if [ ! "x$DATA_WIPE" = "x1" ]; then
		log "check data partition filesystem"
		$FSCKEXT4 $FSCK_ARGS $ROOT_RWDEVICE && EXIT_CODE=$? || EXIT_CODE=$?
		[[ "x$EXIT_CODE" = "x0" ]] && return
		[[ "x$EXIT_CODE" = "x1" ]] && return
		[[ "x$EXIT_CODE" = "x2" ]] && log "reboot the system" && reboot
		log "unhandled exception was occurred";
	fi
}

mount_and_boot() {
	# log "mkdir -p $ROOT_MOUNT $ROOT_ROMOUNT $ROOT_RWMOUNT"
	mkdir -p $ROOT_MOUNT $ROOT_ROMOUNT $ROOT_RWMOUNT

	# Mount root file system as read only.
	ROOT_ROMOUNTPARAMS="-t $ROOT_ROFSTYPE -o ${ROOT_ROMOUNTOPTIONS_DEVICE} $ROOT_RODEVICE"
	# log "$MOUNT $ROOT_ROMOUNTPARAMS $ROOT_ROMOUNT"
	if ! $MOUNT $ROOT_ROMOUNTPARAMS "$ROOT_ROMOUNT"; then
		fatal "Could not mount rootfs as read-only"
	fi

	# Mount data file system as read-write.
	ROOT_RWMOUNTPARAMS="-t $ROOT_RWFSTYPE -o $ROOT_RWMOUNTOPTIONS_DEVICE $ROOT_RWDEVICE"
	# log "$MOUNT $ROOT_RWMOUNTPARAMS $ROOT_RWMOUNT"
	if ! $MOUNT $ROOT_RWMOUNTPARAMS $ROOT_RWMOUNT ; then
		fatal "Could not mount read-write rootfs"
	fi

	# Determine if the overlay file-system is available.
	if ! grep -w "overlay" /proc/filesystems >/dev/null; then
		fatal "overlay is not available as a file-system"
	fi

	mkdir -p $ROOT_RWMOUNT/upperdir $ROOT_RWMOUNT/work
	$MOUNT -t overlay overlay \
		-o "$(printf "%s%s%s" \
			"lowerdir=$ROOT_ROMOUNT," \
			"upperdir=$ROOT_RWMOUNT/upperdir," \
			"workdir=$ROOT_RWMOUNT/work")" \
		$ROOT_MOUNT

	# Move read-only and read-write root file system into the overlay
	# file system
	mkdir -p $ROOT_MOUNT/$ROOT_ROMOUNT $ROOT_MOUNT/$ROOT_RWMOUNT
	$MOUNT -n --move $ROOT_ROMOUNT ${ROOT_MOUNT}/$ROOT_ROMOUNT
	$MOUNT -n --move $ROOT_RWMOUNT ${ROOT_MOUNT}/$ROOT_RWMOUNT

	$MOUNT -n --move /proc ${ROOT_MOUNT}/proc
	$MOUNT -n --move /sys ${ROOT_MOUNT}/sys
	$MOUNT -n --move /dev ${ROOT_MOUNT}/dev

	cd $ROOT_MOUNT

	exec chroot $ROOT_MOUNT $INIT ||
		fatal "Couldn't chroot, dropping to shell"
}

wait_for_device
check_factory_reset
check_datapartition
mount_and_boot
