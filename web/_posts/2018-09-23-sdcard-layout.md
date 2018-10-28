---
layout: post
title:  "Modifying the SD Card layout"
excerpt_separator: <!--more-->
---
CattlePi does not really care about the way the SD card is partition and formatted. As long as your Pis boot and there is enough space on the boot partition to cache the CattlePi images you should be good (usually the first partition, needs to be FAT and it's recommended that it has 1G+ of space so that there is enough room to cache the images). 

That being said, in a particular setup you may care about how the card is partitioned. We've made it easy by adding a configuration option that (if present) will alter the SD card layout to whatever is specified in there. 

<!--more-->

**WARNING: Whenever you specify the option you will lose any data on the SD Card. Please backup important data you may have and/or choose to use an empty SD Card.**

The option you can specify in the config is called sdlayout and is nested under the config key in the device boot configuration. 

A sample configuration:
```bash
{
  "bootcode": "",
  "config": {
    "sdlayout": "bGFiZWw6IGRvcwpkZXZpY2U6IC9kZXYvbW1jYmxrMAp1bml0OiBzZWN0b3JzCgovZGV2L21tY2JsazBwMSA6IHN0YXJ0PSAgICAgICAgMjA0OCwgc2l6ZT0gICAgIDgxOTIwMDAsIHR5cGU9YgovZGV2L21tY2JsazBwMiA6IHN0YXJ0PSAgICAgODE5NDA0OCwgc2l6ZT0gICAgMTAyNDAwMDAsIHR5cGU9ODMKL2Rldi9tbWNibGswcDMgOiBzdGFydD0gICAgMTg0MzQwNDgsIHNpemU9ICAgIDEzMzEyMDAwLCB0eXBlPTgzCi9kZXYvbW1jYmxrMHA0IDogc3RhcnQ9ICAgIDMxNzQ2MDQ4LCBzaXplPSAgICAgNDA5NjAwMCwgdHlwZT1iCg==",
    "ssh": {
      "pi": {
        "authorized_keys": [
          "<<your key here>>"
        ]
      }
    }
  },
  "initfs": {
    "md5sum": "aac02886e82573e19d1f3ecf62a9f760",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v7/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "e43fe03f9fb64f8814904e76990d4104",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v7/rootfs.sqsh"
  },
  "usercode": ""
}
```
As you may notice, the value associated with the key is base64 encoded (the same way bootcode and usercode are base64 encoded if present).  
In this case, decoding the sdlayout value yields:
```bash
label: dos
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=     8192000, type=b
/dev/mmcblk0p2 : start=     8194048, size=    10240000, type=83
/dev/mmcblk0p3 : start=    18434048, size=    13312000, type=83
/dev/mmcblk0p4 : start=    31746048, size=     4096000, type=b
```

The format is the one the sfdisk command line utility uses. [More here](https://manpages.debian.org/stretch/util-linux/sfdisk.8.en.html) 

This means that you can partition a prototype SD card using whatever tools you want, dump and base64 encode the configuration and after that use it on any number of Pis that have the same size SD card and it will just work out of the box for you.  

A few clarifications: 
 * the CattlePi initramfs scripts will apply the sd config for you and preserve what's on the boot partition, but the first partition needs to be a FAT partition (type=b). Using a different partition type may mean that your Pi will not boot.
 * after the layout is performed, partitions with type=b will be formatted as FAT32 and partition with type=83 will be formatted as ext4. 
 * once a layout is correctly done, the CattlePi boot process will not attempt to redo the layout (runs once - we want prevent situation in which you want to tweak things and/or expand partition and the layout would kill your modifications on next boot). If you want to re-run, you need to remove the /boot/sdlayout.json file (where /boot mounted on /dev/mmcblk0p1)


Full details on how this works in [the PR that implements it](https://github.com/cattlepi/cattlepi/pull/31)