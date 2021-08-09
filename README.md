SRG-IM8P Yocto BSP
===

The BSP for **AAEON SRG-IM8P IoT Gateway**.
to integration [SWUpdate](https://sbabic.github.io/swupdate/) support,
base on **NXP offical BSP 5.10.9_1.0.0 (gatesgarth)** and to extend new feature.

### extend new features include the below
* **Over-The-Air update**, support with **Eclipse Hawkbit**
* **Offline update**, auto detection/update when update package on USB disk
* **Factory reset/Data wipe** by command ***datawipe***
* **Secure Boot**, only booting from signed bootloader & kernel image when enabled the feature
* **Secure software update package**, to use RSA key signing/verify update package

### srg-im8p-image include the below software packages
* imx-image-multimedia
* imx machine learning
* tpm2-tools
* swupdate
* stressapptest and memtest
* and others....

### Verify the below hardware interface passed
* EMMC/SD card, for installer and normal operation
* USB, access USB storage and connection FTDI UART chip on board
* RTC, for setting date and time passed
* NIC, ssh login/operation passed
* TPM, selftest and getcap passed
* HDMI, screen display passed

Usage:

* [Build steps](./doc/BUILD.md)
* [HW verify](./doc/HW_VERIFY.md)
* [Update OTA and Offline](./doc/UPDATE.md)
* [Secure boot](./doc/SECUREBOOT.md)
* [Factory reset](./doc/DATAWIPE.md)

### References:
1. [NXP offical BSP](https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX?tab=In-Depth_Tab) release page
