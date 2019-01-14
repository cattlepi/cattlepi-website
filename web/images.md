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

## Available prebuilt recipe images
There are 3 recipes that get automatically build periodically. These include:  

**raspbian_cattlepi**  
This is the default Cattlepi image   
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_cattlepi.yml)   
To build this yourself: [make raspbian_cattlepi](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L9)

**raspbian_pihole**
This image has PiHole baked into it.  
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_pihole.yml)  
To build this yourself: [make raspbian_pihole](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L25)  

**raspbian_stock**
This image will write place stock raspbian on your SDCard (need the SD card to be in a compatible layout or you need to associate the proper sdlayout to enable it)  
Recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_stock.yml)  
To build this yourself: [make raspbian_stock](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L21)  

***In general all the images that are referenced by the API will be preserved and the ones that are not in use will be garbage collected periodically.***  If you want to ensure that the image you are using is not removed be sure to reference it in a configuration or persist it somewhere else and after that reference it from there. 

## The current prebuilt available images
For each set of images there is a build id (that captures a timestamp) and underneath that build id you have the pointers and the checksums for the images themselves.  

{% include_relative assets/prebuild.md %}

## Build your own images
Learn how to build your own images here: [BUILDING.md](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md)
