---
layout: page
title: Images
permalink: /images/
---

Currently available images.  
You can reference these (along with the associated md5sum in your device boot configurations).  

## How to translate this images into boot config?
Translate the given shell variables  into something you can use against the cattlepi api to program the boot target for specific devices. 

Example:
```bash
APIKEY=your_api_key_goes_here
PAYLOAD='{"config":{"autoupdate":true,"ssh":{"pi":{"authorized_keys":["'$(head -1 $HOME/.ssh/id_rsa.pub)'"]}}},"initfs":{"md5sum":"'${INITFSMD5}'", "url":"'${INITFS}'"},"rootfs":{"md5sum":"'${ROOTFSMD5}'","url":"'${ROOTFS}'"}}'
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: $API_KEY" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config
```

## Available prebuilt images
### Raspbian Stretch Lite - CattlePi Build (v8)
This is the default Cattlepi image   
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_cattlepi.yml)  
To build this: [make raspbian_cattlepi](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L9)  
```bash
#generated on Sat Sep 29 19:05:35 PDT 2018
INITFS=https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v8/initramfs.tgz
INITFSMD5=63523e54a3f49918ac3a9a790154e76f
ROOTFS=https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v8/rootfs.sqsh
ROOTFSMD5=5c0318793df00f36244d7ee888f809e7
```

### Raspbian Stretch - Stock Build (v9)
This image will write place stock raspbian on your sdcard (need the sd card to be in a compatible layout or you need to associate the proper sdlayout to enable it)  
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_stock.yml)  
To build this: [make raspbian_stock](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L21)  
```bash
# generated on Sun Oct  7 20:53:31 PDT 2018
INITFS=https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v9/initramfs.tgz
INITFSMD5=1bc253db8b243c84f2c41b2485d77021
ROOTFS=https://api.cattlepi.com/images/global/raspbian-stock/2018-06-29/v9/rootfs.sqsh
ROOTFSMD5=82cf5bda1b2fa2da252ab41d3b28b8d7
```

### Raspbian Stretch Lite - Pihole (v8)
This image has PiHole baked into it.  
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_pihole.yml)  
To build this: [make raspbian_pihole](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L25)  
```bash
# generated on Sun Sep 30 22:33:50 PDT 2018
INITFS=https://api.cattlepi.com/images/global/raspbian-pihole/2018-06-29/v8/initramfs.tgz
INITFSMD5=fc9deaedfb0a2701138535f0878aa752
ROOTFS=https://api.cattlepi.com/images/global/raspbian-pihole/2018-06-29/v8/rootfs.sqsh
ROOTFSMD5=e009a7ca757d32f6783745c50e9a2411
```

## Build your own images
Learn how to build your own images here: [BUILDING.md](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md)
