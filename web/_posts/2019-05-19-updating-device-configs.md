---
layout: post
title:  "Updating device config - easier path"
excerpt_separator: <!--more-->
---
Up until this point we have shown you how to update various parts of the device configuration manually (e.g. [Autoupdate Configuration]({% post_url 2018-09-23-autoupdate %}))  
This works and it's important in understanding details about which configuration keys map to which feature but it can be a little tedious, expecially if you're updating a lot of configs or if you have special configuration. Up until now you would probably be force to have a few small shell scripts that retrieve, parse and update the cofiguration in order not have to remember all the details (or keep referencing the documentation). Now we have added a tool directy in the cattlepi repository to make the job of updating device configurations trivial. See: [https://github.com/cattlepi/cattlepi/tree/master/tools/api](https://github.com/cattlepi/cattlepi/tree/master/tools/api)

<!--more-->
The two scripts are **account_device_config_get.sh** and **account_device_config_update.sh**  

Assuming your API_KEY is stored in an environment variable, ot look at the device config you would do:
```bash
account_device_config_get.sh -k ${API_KEY} | jq .
```
and get the configuration associated with the default device:
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": false,
    "sdlayout": <your sdlayout>>,
    "ssh": {
      "pi": {
        "authorized_keys": [
          <<your authorized key>>
        ]
      }
    }
  },
  "initfs": {
    "md5sum": "56b748392f4154bb425856a29d499376",
    "url": "https://api.cattlepi.com/images/global/autobuild/raspbian_stock/2019_05_13_161246/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "b4c606dd5e289ed66517abd57f6a7842",
    "url": "https://api.cattlepi.com/images/global/autobuild/raspbian_stock/2019_05_13_161246/rootfs.sqsh"
  },
  "usercode": ""
}
```
Now assume you would want to set the device to autoupdate as described in the earlier link. You would need to do:
```bash
./account_device_config_update.sh -i -pca -k ${API_KEY}
```
That's it. The -i flags means that the configuration is applied incrementally (as a delta on the existing config) and the -pca sets the autoupdate flag.  
To see all the options and additional examples you can do:
```bash
./account_device_config_update.sh --help
Usage: account_device_config_update.sh [options]

  Mandatory arguments:

    -k, --api-key API_KEY           provides the api key to use when making the calls

  Optional arguments (pass any or a combination of them - usually each touches a different part of the config)

    -a --api-endpoint API_ENDPOINT  provides the api endpoint to use when
                                    making the calls (default: https://api.cattlepi.com)
    -d --device DEVICE              target device (default: default)
    -i --incremental                if specified the current configuration is updated
                                    after being retrieved from the api. if not config is built from scratch
    -hkb --hook-before FILE         executable to invoke before performing the updates (used in automation)
    -hka --hook-after FILE          executable to invoke after performing the updates (used in automation)
    -pb --payload-bootcode FILE     file containing the payload we want to put in the bootcode field
    -pu --payload-usercode FILE     file containing the payload we want to put in the usercode field
    -pca --payload-config-autoupdate    set autoupdate flag to true (if not specified set to false)
    -pcs --payload-config-sdlayout FILE   file containing the sdlayout we want to use
    -iiu --image-initfs-url URL     initfs image url we want to use
    -iim --image-initfs-md5sum MD5    md5sum for the initfs image
    -iru --image-rootfs-url URL     rootfs image url we want to use
    -irm --image-rootfs-md5sum MD5  md5sum for the rootfs image
    -ipkg --image-packaged-config URL   passes in an url that contains iiu,iim,iru,irm as vars
    -sshak --ssh-add-public-key FILE    add the public key found in the specified file
    -sshadk --ssh-add-default-public-key   add the public key found in HOME/.ssh/id_rsa.pub
    -so --show-only                 only show what the config generated would be without issuing the update

  Clarification on combinining certain options:
    1) passing in -ipkg will override all previously defined -i?? options
    2) you can use sshak or sshadk but not both. last option specified will take priority
    3) for bootcode, usercode and sdlayout options you can pass in WIPE instead of a filename to remove what is currently defined


  Examples (assumes TEST_API_KEY has you api key):

  Set the bootcode to the contents of the /tmp/zoo file:
    account_device_config_update.sh -k $TEST_API_KEY -i -pb /tmp/zoo

  Set the sdlayour to the contents of the default_sfdisk file:
    account_device_config_update.sh -k $TEST_API_KEY -i -pcs /tmp/default_sfdisk

  Set the autoupdate behavior to on:
    account_device_config_update.sh -k $TEST_API_KEY -i -pca

  Update the initfs used:
    account_device_config_update.sh -k $TEST_API_KEY -i -iiu https://api.cattlepi.com/images/global/autobuild/raspbian_cattlepi/2019_02_01_114249/initramfs.tgz -iim 10ee8171691d091f8ee708271f695d97

  Use the ipkg to update both initfs and roots urls and md5s at the same time:
    account_device_config_update.sh -k $TEST_API_KEY -i -ipkg https://api.cattlepi.com/images/global/autobuild/raspbian_cattlepi/2019_02_01_114249/info.sh

  Simulate an update (show only used):
    account_device_config_update.sh -k $TEST_API_KEY -i -pca -so

 More documetation on: https://cattlepi.com/
```

The most used option (anticipated) would be the ipkg one for updating the images. This allows to update both the initfs and rootfs and their coresponding checksums in one go by referencing a valid info.sh (and listed in the [Images]({% link images.md %})) or build by one of your own recipes)
An example:  
```bash
./account_device_config_update.sh -k ${API_KEY} -i -ipkg https://api.cattlepi.com/images/global/autobuild/raspbian_stock/2019_05_13_161246/info.sh
```