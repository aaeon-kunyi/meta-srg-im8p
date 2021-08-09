Factory reset
===

the mechanism base on readonly root filesystem with overlay filesystem.
all operation only on data partition.

### verify method

1. to change any settings and file on device

   * to change any file or add/delete some files
   * to change something system settings. for example: hostname
   * to **poweroff** or **reboot** for verify your operation keep on device

1. run **datawipe** command

   the system will auto reboot, the system will reset to factory setting and lost all user change
