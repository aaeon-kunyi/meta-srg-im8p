#!/bin/sh

# Enable strict shell mode
set -euo pipefail

PATH=/sbin:/bin:/usr/sbin:/usr/bin

MOUNT="/bin/mount"
UMOUNT="/bin/umount"
INIT="/sbin/init"

ROOT_DEVICE=""
ROOT_MOUNT="/mnt/root"

#ROOT_FSTYPE="squashfs"
#ROOT_MOUNTOPTIONS_DEVICE=""

ROOT_FSTYPE="ext4"
ROOT_MOUNTOPTIONS_DEVICE="ro,noatime,nodiratime"

early_setup() {
	mkdir -p /proc
	mkdir -p /sys
	$MOUNT -t proc proc /proc
	$MOUNT -t sysfs sysfs /sys
	grep -w "/dev" /proc/mounts >/dev/null || $MOUNT -t devtmpfs none /dev
}

read_args() {
	[ -z "${CMDLINE+x}" ] && CMDLINE=`cat /proc/cmdline`
	for arg in $CMDLINE; do
		# Set optarg to option parameter, and '' if no parameter was
		# given
		optarg=`expr "x$arg" : 'x[^=]*=\(.*\)' || echo ''`
		case $arg in
			root=*)
				ROOT_DEVICE=$optarg ;;
			rootfstype=*)
				ROOT_FSTYPE="$optarg" ;;
			init=*)
				INIT=$optarg ;;
		esac
	done
}

fatal() {
	echo "ro-init: $1" >$CONSOLE
	echo >$CONSOLE
	exec sh
}

log() {
	echo "ro-init: $1" >$CONSOLE
}

wait_for_device() {
	while [ ! -b $ROOT_DEVICE ]; do
		sleep 1
		log "waiting for $ROOT_DEVICE"
	done
}

early_setup

[ -z "${CONSOLE+x}" ] && CONSOLE="/dev/console"

read_args

mount_and_boot() {
	mkdir -p $ROOT_MOUNT

	# Mount root file system as read only.
	ROOT_MOUNTPARAMS="-t $ROOT_FSTYPE -o ${ROOT_MOUNTOPTIONS_DEVICE} $ROOT_DEVICE"
	log "$MOUNT $ROOT_MOUNTPARAMS $ROOT_MOUNT"
	if ! $MOUNT $ROOT_MOUNTPARAMS "$ROOT_MOUNT"; then
		fatal "Could not mount rootfs as read-only"
	fi

	# Move read-only root file system
	$MOUNT -n --move /proc ${ROOT_MOUNT}/proc
	$MOUNT -n --move /sys ${ROOT_MOUNT}/sys
	$MOUNT -n --move /dev ${ROOT_MOUNT}/dev

	touch /tmp/machine-id
	mount --bind /tmp/machine-id ${ROOT_MOUNT}/etc/machine-id

	cd $ROOT_MOUNT
	exec chroot $ROOT_MOUNT $INIT ||
		fatal "Couldn't chroot, dropping to shell"
}

wait_for_device
mount_and_boot
