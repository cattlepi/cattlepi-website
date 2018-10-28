---
layout: post
title:  "Hello CattlePi - getting started with api.cattlepi.com"
excerpt_separator: <!--more-->
---
This post will show you how to get started with cattlepi.
We assume you already have a [supported](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md#what-types-of-hardware-does-this-work-on) Raspberry Pi and an empty SD card you can use.
<!--more-->

We also asume that the Pi is on a network in which it will receive an IP Address through DHCP and will be have internet connectivity (assuming network is correctly configured on the PI)  

# Step 1 - Downloading the bootstrap cattlepi image
Follow the instructions here: [https://github.com/cattlepi/cattlepi#quickstart](https://github.com/cattlepi/cattlepi#quickstart)  
In normal operation you should not need a monitor (ie your Pi can run headless) but it's recommended to have one for the first boot so that you can observe the process. 

After the boot the card will have the latest **initfs** and **rootfs** images that are configured for the default device for the demo api key (ie **deadbeef**).  
To see what those are visit or curl the following link: [https://api.cattlepi.com/boot/default/config?apiKey=deadbeef](https://api.cattlepi.com/boot/default/config?apiKey=deadbeef)

Sample curl request:
```bash
curl -s https://api.cattlepi.com/boot/default/config?apiKey=deadbeef | jq .
```

Sample output (may vary at a later point in the future):
```json
{
  "bootcode": "",
  "config": {},
  "initfs": {
    "md5sum": "8e0e2870637e77462b40b8fe67c6d91b",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "0826222b56df3d074fa4b21fd4b9d891",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/rootfs.sqsh"
  },
  "usercode": ""
}

```
You can observe the images that are used under the *initfs.url* and *rootfs.url* keys. These are the images that will get downloaded and persisted on the SD card.  

# Step 2 - Requestion your own API Key
Using the demo api key is fine, but due to its shared nature you cannot do much with it. To be able to unleash the full possiblities of the API you will need to request your own API Key.  

Head over to the [API]({% link api.md %}) section and request your own API Key.  
You need to provide a valid email address and after your API Key is assigned you will receive an link with instructions on how to activate it.   

For example, going through process I received and activated the following API Key: 
```bash
8db071a4-63ef-47f7-9cfc-ca479b5422da
```

# Step 3 - Use the new API Key
Let's use your API key.  
There are two ways to do this (either of them works):
 * build your own image as described [here](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md). You will need to use your API Key.  
 * update the SDCard to use your API Key  

Since this is a Hello World, we'll use the latter.  
Power down the Pi and remove the SDCard. Attach/Mount the SDCard to your machine and let's inspect the contents.  

In the root of the SDCard we'll do:
```bash
s -lah
total 34M
drwxr-xr-x 4 root root 4.0K Dec 31  1969 .
drwxr-xr-x 4 root root 4.0K Aug 10 17:28 ..
-rwxr-xr-x 1 root root  22K Aug  7 22:37 bcm2708-rpi-0-w.dtb
-rwxr-xr-x 1 root root  22K Aug  7 22:37 bcm2708-rpi-b.dtb
-rwxr-xr-x 1 root root  22K Aug  7 22:37 bcm2708-rpi-b-plus.dtb
-rwxr-xr-x 1 root root  22K Aug  7 22:37 bcm2708-rpi-cm.dtb
-rwxr-xr-x 1 root root  23K Aug  7 22:37 bcm2709-rpi-2-b.dtb
-rwxr-xr-x 1 root root  24K Aug  7 22:37 bcm2710-rpi-3-b.dtb
-rwxr-xr-x 1 root root  25K Aug  7 22:37 bcm2710-rpi-3-b-plus.dtb
-rwxr-xr-x 1 root root  23K Aug  7 22:37 bcm2710-rpi-cm3.dtb
-rwxr-xr-x 1 root root  51K Aug  7 22:37 bootcode.bin
-rwxr-xr-x 1 root root  13M Aug  7 22:37 cattleinit.cpio
drwxr-xr-x 2 root root 4.0K Aug 10 17:53 cattlepi
-rwxr-xr-x 1 root root  161 Aug  7 22:37 cmdline.txt
-rwxr-xr-x 1 root root 1.7K Aug  7 22:37 config.txt
-rwxr-xr-x 1 root root  19K Aug  7 22:37 COPYING.linux
-rwxr-xr-x 1 root root 2.6K Aug  7 22:37 fixup_cd.dat
-rwxr-xr-x 1 root root 6.5K Aug  7 22:37 fixup.dat
-rwxr-xr-x 1 root root 9.7K Aug  7 22:37 fixup_db.dat
-rwxr-xr-x 1 root root 9.7K Aug  7 22:37 fixup_x.dat
-rwxr-xr-x 1 root root   33 Aug 10 17:55 initfs
-rwxr-xr-x 1 root root  145 Aug  7 22:37 issue.txt
-rwxr-xr-x 1 root root 4.7M Aug  7 22:37 kernel7.img
-rwxr-xr-x 1 root root 4.5M Aug  7 22:37 kernel.img
-rwxr-xr-x 1 root root 1.5K Aug  7 22:37 LICENCE.broadcom
-rwxr-xr-x 1 root root  19K Aug  7 22:37 LICENSE.oracle
drwxr-xr-x 2 root root  12K Aug 10 17:55 overlays
-rwxr-xr-x 1 root root 660K Aug  7 22:37 start_cd.elf
-rwxr-xr-x 1 root root 4.9M Aug  7 22:37 start_db.elf
-rwxr-xr-x 1 root root 2.8M Aug  7 22:37 start.elf
-rwxr-xr-x 1 root root 3.9M Aug  7 22:37 start_x.elf
```
If this looks terribly familiar to what one would see on a Raspberry Pi under /boot it is because it's more or less what you would see under boot with a few additions:
 * the cattleinit.cpio contains the ramdisk image that is used in the boot process. Because it's a cpio file you can open it up and inspect the contents. All of the update logic is there.
 * the cattlepi dir contains the images we are caching and a config file (which is the output of the same earlier curl command)
 * the initfs file hold the checksum that the *initfs* image that resulted in this setup had (this is how the loader know when to update)
 * the config.txt file (present on all Pis) instructs the bootloaded to load the cattleinit.cpio file in memory, right after the kernel (relevant line is: *initramfs cattleinit.cpio followkernel*)
 * finally the cmdline.txt (passed to the kernel) contains the bootparameters for the kernel

```bash
cat cmdline.txt | tr " " "\n"
dwc_otg.lpm_enable=0
console=tty1
boot=cattlepi
cattlepi_base=https://api.cattlepi.com
cattlepi_apikey=deadbeef
initrd=-1
elevator=deadline
rw
rootwait
panic=20
```

We've broken this down into multiple lines to observe it but in the file it's only 1 line.
The cattlepi_api tell the what api endpoint we will use. The cattlepi_apikey tells what api key we're going to use.

An obvious idea is to update the cattlepi_apikey to use our API key. If you were to update it, unmount the SDCard, insert in into the Pi and boot you would observe this would work. There is one problem though. 

Because the cmdline.txt is part of the image, if your configuration instructs the loaded to pick up another **initfs** it will get overwritten by whatever is that **initfs**. So it's going to work until the next update. 

Fortunatelly there is one place where the API key does not get overwritten. If we have a file named **/cattlepi/apikey** the API key will be loaded from that file and will override the kernel parameters one (see logic [here]( https://github.com/cattlepi/cattlepi/blob/2c2d2100c8538f8df34adb31c1db1c2004f152da/templates/raspbian/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers))

In the root of SDcard do:
```bash
sudo bash -c "echo 8db071a4-63ef-47f7-9cfc-ca479b5422da > cattlepi/apikey"
```
Be sure to replace 8db071a4-63ef-47f7-9cfc-ca479b5422da with your own api key.
Also be sure to verify that the apikey was properly written:
```bash
cat cattlepi/apikey 
8db071a4-63ef-47f7-9cfc-ca479b5422da
```
If everythign looks good unmount the SDCard and place it in the Raspberry Pi.
Boot is up.

# Step 4 - Controlling the boot targets for your Pi.
In the previous step you've added you requested you own API key and injected it into the SDCard. Power up and boot the Raspberry Pi.  
You will notice that the Raspberry Pi has issues booting and it fails with a HTTP 404 (ie not found).  
This happens because you have not configured a boot or default boot target using your API key. Remember https://api.cattlepi.com/boot/default/config at step 1. This was actually the boot configuration for the **default** target. 

Each Raspberry Pi device that you want to associate with this API Key needs to have an unique id. By default if you don't specify any the mac address of the hardware is the unique id.  

The when booting the the loader will attempt to go retrieve the configuration from:  
```bash
https://api.cattlepi.com/boot/<unique_id>/config
```

In the back the API will recognize this and will try to find the config for the specific device. If found it will use that config. If not found it will attempt to locate the default config. If that's found the default is server. If neither are found you get the 404 that you're experiencing now. 

Why have a default boot configuration target? The thinking here is that you should be able to connect your devices and have them use a generic boot target without having to worry about their ids. Later, if you want to specialize certain devices to do certain things you can easily inspect a list of deviceids that talked to the API and use them to specialize the devices.  

Right now let's create a default boot target, using our api key:
```bash
curl -vvv -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    -X POST -d '{"initfs":{"md5sum":"8e0e2870637e77462b40b8fe67c6d91b", "url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/initramfs.tgz"},"rootfs":{"md5sum":"0826222b56df3d074fa4b21fd4b9d891","url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/rootfs.sqsh"}}' \
    https://api.cattlepi.com/boot/default/config
```

with the response of 
```bash
> POST /boot/default/config HTTP/1.1
> Host: api.cattlepi.com
> User-Agent: curl/7.47.0
> Accept: application/json
> Content-Type: application/json
> X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da
> Content-Length: 288
> 
* upload completely sent off: 288 out of 288 bytes
< HTTP/1.1 200 OK
< Date: Sat, 11 Aug 2018 19:08:51 GMT
< Content-Type: application/json
< Content-Length: 16
< Connection: keep-alive
< x-amzn-RequestId: fb8a93a9-9d99-11e8-a3bd-29cf9684cc5c
< x-amz-apigw-id: LeUaeEfcPHcFvEg=
< X-Amzn-Trace-Id: Root=1-5b6f3443-1669693c7e1311e667fe786b;Sampled=0
< 
* Connection #0 to host api.cattlepi.com left intact
{"status": "ok"}
```
So now we have a default boot target. To verify this we can do:
```bash
curl -s -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" https://api.cattlepi.com/boot/default/config | jq .
{
  "bootcode": "",
  "config": {},
  "initfs": {
    "md5sum": "8e0e2870637e77462b40b8fe67c6d91b",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "0826222b56df3d074fa4b21fd4b9d891",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v4/rootfs.sqsh"
  },
  "usercode": ""
}
```

You may be wondering how come the default boot target was there for the demo api key and was not there for our own api key. For all intents and purposes, everything under one API key is isolated. They keys shared the same path as far as the actual API goes but, in the back, they access different data sources. To go even further you could have the same device id (mac) used with multiple api keys and not see any conflicts. This is by design.

Ok. Back to booting the Pi. Now that we have a default boot target let's try booting it. You will notice that the Pi boots just fine now (and can retrive its config).

Before wrapping up, let's try and see if we can find a list of devices that are active under our API key.
```bash
curl -s -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" https://api.cattlepi.com/track | jq .
[
  "default",
  "b8:27:eb:6c:33:e2"
]
```
We've talked about the default boot target (ie not a device per se) and our device is **b8:27:eb:6c:33:e2**  
To inspect details about a specific device:
```bash
curl -s -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" https://api.cattlepi.com/track/b8:27:eb:6c:33:e2 | jq .
[
  "2018-08-11 19:16:28.124746 BOOT GET",
  "2018-08-11 19:17:43.225184 BOOT GET"
]
```

Details on all the supported call are documented in the [API]({% link api.md %}) section.

This concludes our "Hello World" tour. Have fun turning your pet project into a cattle project.