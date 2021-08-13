Fucntion check for Hardware interface
===

### HDMI output
this interface is default video output device. just connection HDMI cable with display.

### EMMC/SD card
first install OS image into EMMC booting from SD card, the mean SD card and on board EMMC operation passed.

### USB disk
offline update will operation with USB Disk.

### RTC
'data -s' & 'hwclock -systohc' run the command for write system clock into external RTC.

### NIC
   OTA verify or ifconfig to check NIC status.

### TPM
use tpm2_tools to verify on board tpm2 chip.

* tpm2_selftest   # for tpm2 selftest
* tpm2_getcap     # for check tpm2 firmware/vendor and another information

#### tpm2_selftest
```
$ tpm2_selftest
```

no any message is passed

#### tpm2_getcap
```
$ tpm2_getcap properties-fixed
TPM2_PT_FAMILY_INDICATOR:
  raw: 0x322E3000
  value: "2.0"
TPM2_PT_LEVEL:
  raw: 0
TPM2_PT_REVISION:
  value: 1.38
TPM2_PT_DAY_OF_YEAR:
  raw: 0x8
TPM2_PT_YEAR:
  raw: 0x7E2
TPM2_PT_MANUFACTURER:
  raw: 0x4E544300
  value: "NTC"
TPM2_PT_VENDOR_STRING_1:
  raw: 0x4E504354
  value: "NPCT"
TPM2_PT_VENDOR_STRING_2:
  raw: 0x37357800
  value: "75x"
TPM2_PT_VENDOR_STRING_3:
  raw: 0x2010024
  value: ""
TPM2_PT_VENDOR_STRING_4:
  raw: 0x726C7300
  value: "rls"
TPM2_PT_VENDOR_TPM_TYPE:
  raw: 0x0
TPM2_PT_FIRMWARE_VERSION_1:
  raw: 0x70002
TPM2_PT_FIRMWARE_VERSION_2:
  raw: 0x10000
TPM2_PT_INPUT_BUFFER:
  raw: 0x400
TPM2_PT_HR_TRANSIENT_MIN:
  raw: 0x5
TPM2_PT_HR_PERSISTENT_MIN:
  raw: 0x5
TPM2_PT_HR_LOADED_MIN:
  raw: 0x5
TPM2_PT_ACTIVE_SESSIONS_MAX:
  raw: 0x40
TPM2_PT_PCR_COUNT:
  raw: 0x18
TPM2_PT_PCR_SELECT_MIN:
  raw: 0x3
TPM2_PT_CONTEXT_GAP_MAX:
  raw: 0xFFFFFFFF
TPM2_PT_NV_COUNTERS_MAX:
  raw: 0x0
TPM2_PT_NV_INDEX_MAX:
  raw: 0x800
TPM2_PT_MEMORY:
  raw: 0x6
TPM2_PT_CLOCK_UPDATE:
  raw: 0x400000
TPM2_PT_CONTEXT_HASH:
  raw: 0xC
TPM2_PT_CONTEXT_SYM:
  raw: 0x6
TPM2_PT_CONTEXT_SYM_SIZE:
  raw: 0x100
TPM2_PT_ORDERLY_COUNT:
  raw: 0xFF
TPM2_PT_MAX_COMMAND_SIZE:
  raw: 0x800
TPM2_PT_MAX_RESPONSE_SIZE:
  raw: 0x800
TPM2_PT_MAX_DIGEST:
  raw: 0x30
TPM2_PT_MAX_OBJECT_CONTEXT:
  raw: 0x714
TPM2_PT_MAX_SESSION_CONTEXT:
  raw: 0x148
TPM2_PT_PS_FAMILY_INDICATOR:
  raw: 0x1
TPM2_PT_PS_LEVEL:
  raw: 0x0
TPM2_PT_PS_REVISION:
  raw: 0x103
TPM2_PT_PS_DAY_OF_YEAR:
  raw: 0x0
TPM2_PT_PS_YEAR:
  raw: 0x0
TPM2_PT_SPLIT_MAX:
  raw: 0x80
TPM2_PT_TOTAL_COMMANDS:
  raw: 0x71
TPM2_PT_LIBRARY_COMMANDS:
  raw: 0x68
TPM2_PT_VENDOR_COMMANDS:
  raw: 0x9
TPM2_PT_NV_BUFFER_MAX:
  raw: 0x400
TPM2_PT_MODES:
  raw: 0x1
  value: TPMA_MODES_FIPS_140_2
```

### Burn-In System
run **'stressapptest'**

### References:
1. [stressapptest](https://github.com/stressapptest/stressapptest), for burn-in system
