Secure boot
===

## Tips: OCOTP fuse **CANNOT be UNDONE**, Careful all steps are corrected

NXP i.MX8M Family support HAB(HAB High Assurance Boot v4) Secure Boot
about concept and detail please read NXP official document.

the BSP will automatic signing bootloader and kernel image when enabled secure boot feature

### 1. Use signed image booting

use signed image on device

### 2. Write key hash value into OCOTP

#### Tips: the example value only for demo, you need change for your device or model

on device need to to write OCOTP(On Chip One-Time Programmable) fuse by bootloader

to break booting process when U-Boot show message
and run the below example instructions

the hash value from **hab_fuse.txt** when run **./gen-cst-swu.sh**
```
fuse prog -y 6 0 0x1F445942
fuse prog -y 6 1 0x7840061B
fuse prog -y 6 2 0xDEB73465
fuse prog -y 6 3 0xC85C7167
fuse prog -y 7 0 0xA61A0075
fuse prog -y 7 1 0x4028DE49
fuse prog -y 7 2 0xF1CEA557
fuse prog -y 7 3 0x07453759
```
the example hash for [${BSP_DIR}/doc/backup_keys/cst_keys.tgz](./backup_keys/cst_keys.tgz)

### 3. Reboot the device for check HAB status

still to break booting process, stay on prompt of U-Boot.
```
hab_status
```

**if you result same the following message, to do next step**
```
 Secure boot disabled

 HAB Configuration: 0xf0, HAB State: 0x66
 No HAB Events Found!
```

### 4. Enable secure boot feature

to close device for enabled secure boot.

#### the device **damage** to brick system if step 2 & step 3 error and run the step

```
fuse prog 1 3 0x02000000
```

the device on booting with signed image now.

### References:
1. [NXP i.MX8M Secure boot](https://source.codeaurora.org/external/imx/uboot-imx/tree/doc/imx/habv4/guides/mx8m_secure_boot.txt?h=lf_v2020.04), NXP i.MX8M secure boot/habv4
2. [AN4581 - i.MX Secure Boot on HABv4 Supported Devices](https://www.nxp.com/docs/en/application-note/AN4581), requirement login NXP website
