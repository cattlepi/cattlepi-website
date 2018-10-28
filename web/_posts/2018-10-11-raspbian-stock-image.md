---
layout: post
title:  "Setting up a Raspbian stock image"
excerpt_separator: <!--more-->
---
The basic principle of the CattlePi project is that "**we want to turn your pet projects into cattle projects**". This means that, ideally, you would keep zero state on the Raspberry Pi devices in your fleet and you would dynamically figure out what the Pi should be running either at boot time or periodically at runtime.    
That's how we envision you will be using CattlePi.  

That being said there are times when you do want a stock Raspbian install and you do want to leverage Raspbian in exactly the same way you would if you were to write it to the SD card yourself.  

 <!--more-->

Because, at the end of the day, we are pragmatic and we want to enable you to use your Pi however you want we've put together a recipe that allows you to write a Raspbian Lite Stock image directly on the SD card.  

CattlePi will control the Pi only long enough to write the image and after that it will hand over the full control to the Stock Raspbian image. (via a reboot)  
If you've used something like [etcher](https://etcher.io/) in the past, you can think about this as **etcher-on-the-fly**

Recipe is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_stock.yml)  
To build it: [make raspbian_stock](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L21) 

See the PR that implemented this feature [here](https://github.com/cattlepi/cattlepi/pull/45).  

The important bits are at the end.  

_For completeness, here is how is the stock raspbian we are laying down different from what you would get via something like etcher:_
 * _the root partition is not expanded (raspbian does this on first boot via a somewhat shady mechanism: it point the kernel init to the resize script). The init based script also assumes (reasonable assumption) that the rootfs partition is going to be the last partition. We don't have this limitation_
 * _as mentioned before we install jq_
 * _we run the bootstrap script that allows us to inject the ssh keys (if any) and run the usercode (if any). So this way we can take control over the pi running the stock raspbian via the device boot configuration._

So you'll get the same as stock raspbian with the 3 mentioned differences. 
You need the sd card to be in a compatible layout (compatible layout means at least 2 partitions, the first one being a FAT partition (type b), and the 2nd one being a linux partition (type 83) + the sdcard needs to have a dos mbr) or you need to associate the proper sdlayout to enable it. More on sdlayout in this [previous tutorial]({% post_url 2018-09-23-sdcard-layout %})

Also, here is an example of device boot target configuration configuration that uses this recipe:
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": true,
    "sdlayout": "bGFiZWw6IGRvcwpkZXZpY2U6IC9kZXYvbW1jYmxrMAp1bml0OiBzZWN0b3JzCgovZGV2L21tY2JsazBwMSA6IHN0YXJ0PSAgICAgICAgMjA0OCwgc2l6ZT0gICAgIDgxOTIwMDAsIHR5cGU9YgovZGV2L21tY2JsazBwMiA6IHN0YXJ0PSAgICAgODE5NDA0OCwgc2l6ZT0gICAgMTg0MzIwMDAsIHR5cGU9ODMK",
    "ssh": {
      "pi": {
        "authorized_keys": [
          "your ssh public key"
        ]
      }
    }
  },
  "initfs": {
    "md5sum": "ab926ee004f75f95a74e248669b514ec",
    "url": "https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v8/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "beb384432a55688d82575df40c8daeed",
    "url": "https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v8/rootfs.sqsh"
  },
  "usercode": ""
}
```

The decoded (valid in this case) sdlayout is:
```bash
label: dos
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=     8192000, type=b
/dev/mmcblk0p2 : start=     8194048, size=    18432000, type=83
```

Final note: inside a booted Pi that successfully wrote the stock raspbian to sd card and rebooted you will find a script [**/etc/cattlepi/restore_cattlepi.sh**](https://github.com/cattlepi/cattlepi/blob/master/templates/raspbian_stock/resources/bin/restore_cattlepi.sh) that you can use if you ever want to revert this Pi to being managed by CattlePi. 
Should you ever want to revert make sure you have an up-to-date device boot target config and run this script with root priviledges.

Find the *latest* raspbian stock image info in the [Images]({% link images.md %}) section.