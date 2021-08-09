How to build image
===

### clone the git repository

```
git clone https://github.com/aaeon-kunyi/meta-srg-im8p.git
```
### prepare something for SWUpdate/Secure Boot

```
cd meta-srg-im8p
./gen-cst-swu.sh # for generation sign key CST & SWupdate
```

generate ***hab_fuse.txt*** file on ${BSP_DIR}.
**please keep the file need it for secure boot**

### install docker on host for build

please install [docker engine](https://docs.docker.com/engine/install/ubuntu/) & run [Post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) on host for setup and build.

### build instructions

Build base image command. This command result is generate **srg-im8p-image-srg-im8p.wic.gz**.

```
./kas-container build srg-im8p-image.yaml
```

Build an installer image for flash device from sd card. This command will produce **sd-installer-srg-im8p.wic.gz** when complete.

```
./kas-container build kas/sd-installer.yaml
```

Build swupdate package, to make a software update package.

```
./kas-container build srg-im8p-update.yaml
```

Will make **srg-im8p-update-srg-im8p.swu**

Build sdk/toolchain for end user

```
./kas-container shell srg-im8p-image.yaml -c 'bitbake -c populate_sdk srg-im8p-image'
```

the command will generation **srg-iotgateway-glibc-x86_64-srg-im8p-image-cortexa53-crypto-srg-im8p-toolchain-5.10-gatesgarth.sh** under ${BSP_DIR}/build/tmp/deploy/sdk


if you want enable secure boot feature, to attach **:secureboot.yaml** on tail of build command , for example
```
./kas-container build srg-im8p-image.yaml:secureboot.yaml
./kas-container build kas/sd-installer.yaml:secureboot.yaml
./kas-container build srg-im8p-update.yaml:secureboot.yaml
```
#### build tips

sometime build error like the below message, need manual clean and rebuild

***Exception: subprocess.CalledProcessError: Command '['du', '-ks', '/build/tmp/work/srg_im8p-poky-linux/srg-im8p-image/1.0-r0/rootfs']' died with <Signals.SIGABRT: 6>.***

to use the below instruction to manual **srg-im8p-image**

```
./kas-container shell srg-im8p-image.yaml -c 'bitbake -c cleansstate srg-im8p-image'
```

### References:
1. [kas](https://github.com/siemens/kas), build tools
