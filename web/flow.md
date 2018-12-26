---
layout: page
title: Boot Flow
permalink: /flow/
---

## Steps in the boot process

### Step 0: How the Raspberry Pi boots:
The overall boot RPi boot process has been described over and over again. You can form an idea by looking [here](https://raspberrypi.stackexchange.com/questions/10442/what-is-the-boot-sequence), [here](https://wiki.beyondlogic.org/index.php?title=Understanding_RaspberryPi_Boot_Process) or [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/bootflow.md)

CattlePi specific things:
 * The **initfs** image contains the initramfs and the kernel is instructed via options both in config.txt (initramfs cattleinit.cpio followkernel) and cmdline.txt (initrd=-1) to load and start the initramfs. 
 * Once it starts, it will run the init script within the initramfs. The init script will invoke all the logic needed.  
 
The logic is explaines in all the next steps in this flow.

### Step 1: Ping the API

This verifies that the API is up, and also infers the current time (the Raspberry Pi does not have a real-time clock; knowing the time is vital for https access during the boot process).

`GET https://api.cattlepi.com/ping`

### Step 2: Get the configuration associated with the device

Each Raspberry Pi device should have a configuration associated with it. The device will try to retrieve this configuration, first using its own identified configuration. If that fails, the identifier `default` is used.

By default, the device identifier is its MAC address. This can be over-ridden, and set to whatever you want. However, ideally, you would still desire different IDs for different devices.

`GET https://api.cattlepi.com/boot/{deviceId}/config`  
and, if this fails:  
`GET https://api.cattlepi.com/boot/default/config`  

An example configuration for a device:  
```json
{
  "initfs": {
    "url": "https://api.cattlepi.com/images/global/initramfs.tgz",
    "md5sum": "93a4eccacabdcce8eb5b8b68de6742cc"
  },
  "rootfs": {
    "url": "https://api.cattlepi.com/images/global/rootfs.sqsh",
    "md5sum": "c1d44c65d29af575b2f6685b6a91d2da"
  },
  "bootcode": "",
  "usercode": ""
}
```  
The reason behind the fall-back to the default device ID is that you can use it to detect new devices you've never seen before, and register them — and/or generate their own configurations on the fly.

### Step 3: Download the images specified in the config

From the config, download and store locally the images specified in `initfs.url` and `rootfs.url`. The md5sum for each of these can be used to verify the images. By default this check is off.

### Step 4: Update initfs

If the contents of the boot partition are different to the contents specified via the configuration, the downloaded initfs will be unpacked on the boot partition (i.e. over-writing the contents of the existing files - but not removing additional files) and the device will be rebooted. This ensures that the device always runs with the specified boot partition content. 

### Step 5: Mount the root filesystem and switch to it

The final step of the boot process consists of building the root filesystem. The root is a [Unionfs filesystem](https://en.wikipedia.org/wiki/UnionFS) that has two layers: a bottom, read-only, layer specified in `rootfs.url`, and a top, read/write, layer that is a tmpfs filesystem.

## Implications of this boot flow

To make some implications explicit:
 * the Raspberry Pi needs to be able to acquire a network address through DHCP _and_ needs to be able to do internet traffic. The boot process will fail if either are not met
 * all operations that happen during boot will be re-tried with exponential back-off in case of failure (i.e. failure of one API call does not mean much, and in an unlikely case, it will just add a few additional seconds to the boot - the boot is resilient to transient failures)
 * because of the way this is wired, only one partition is needed on the SD card: the boot partition. As an optimization the downloaded images are stored on this partition. The size of the partition should be enough to accomodate both the boot files themselves and the images. We recommend that the boot partition is at least 1GB in size
 * also because of how this is wired, the SD card is potentially written to only at boot time. Once the Pi has booted and you have the root filesystem, for all intents and purposes the card is only read from (for the lower layer of the union root filesystem)
 * if the images are not already cached, the process to download them may introduce a significant boot delay when the download needs to happen (e.g. if an image is 300M and the internet download speed is 5M/s, the download will take 60 seconds)
 * because of how the root filesystem is built, any changes made to the filesystem will reside in the upper layer of the union and will be lost on reboot. This is good, because it means that all the state you have on the device is expendable, and you can likely rebuild it after a reboot. If you rely on the state of the device, you will have to figure out a state to persist it outside of cattlepi.

## More... 

Inspect the logic and/or deep dive into the [actual code here](https://github.com/cattlepi/cattlepi/tree/master/templates/raspbian_cattlepi/resources/usr/share/initramfs-tools)


