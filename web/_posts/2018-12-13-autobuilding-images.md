---
layout: post
title:  "Autobuilding images"
excerpt_separator: <!--more-->
---
If you've been following the CattlePi project for a while now you should be familiar with the process of building images and updating boot configurations associated with specific devices.  

We now want to take this a step further with a process/script of automatically building images. We will leverage the raspbian_stock image and already existing tooling in the cattlepi code repository.

<!--more-->

We'll need one raspberry pi to act as a builder (we will use this to build the images).  

Here is the boot configuration associated with the builder:  
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": true,
    "sdlayout": "bGFiZWw6IGRvcwpkZXZpY2U6IC9kZXYvbW1jYmxrMAp1bml0OiBzZWN0b3JzCgovZGV2L21tY2JsazBwMSA6IHN0YXJ0PSAgICAgICAgMjA0OCwgc2l6ZT0gICAgIDgxOTIwMDAsIHR5cGU9YgovZGV2L21tY2JsazBwMiA6IHN0YXJ0PSAgICAgODE5NDA0OCwgc2l6ZT0gICAgMTg0MzIwMDAsIHR5cGU9ODMK",
    "ssh": {
      "pi": {
        "authorized_keys": [
          "<<your ssh public key>>"
        ]
      }
    },
    "standalone": {
      "raspbian_location": "http://192.168.1.87/2018-06-27-raspbian-stretch-lite.zip"
    }
  },
  "initfs": {
    "md5sum": "c833b36cfe634d3b1341cc9d309ef440",
    "url": "https://api.cattlepi.com/images/global/autobuild/raspbian_stock/2018_11_30_120049/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "2cb5f6771c8c80feb0346d1fe6c34189",
    "url": "https://api.cattlepi.com/images/global/autobuild/raspbian_stock/2018_11_30_120049/rootfs.sqsh"
  },
  "usercode": ""
}
```

Make sure to find and use the *latest* raspbian stock image info in the [Images]({% link images.md %}) section.

The following section is optional, but can greatly increase build speed if you can host the raspbian-strech-light.zip file somewhere locally near the build machine.
```json
"standalone": {
      "raspbian_location": "http://192.168.1.87/2018-06-27-raspbian-stretch-lite.zip"
}
```  

**You will need to either update the raspbian location or completely remove this for the process to work.** See the stock [bootstrap_recipe.sh](https://github.com/cattlepi/cattlepi/blob/23d32adb78face5f65dd6a9d90e7aa8f134d6038/templates/raspbian_stock/resources/bin/bootstrap_recipe.sh#L9) for the official location from where the image will be downloaded and written if the absence of the standalone section. Also keep in mind that this may be updated at any time.

Make sure the builder is setup and up with the raspbian stock image. 

You will also need to have a working AWS account as the built images are uploaded to S3 for storage. You can read on how to install and configure the awscli tool [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). You also have the option to not use AWS but this will require some changes (ie will not work out of the box and is not covered in this tutorial).

With the prep work, let's use the **build_and_publish.sh** script to build all the images in the cattlepi repository automatically.
```bash
git clone https://github.com/cattlepi/cattlepi.git
source cattlepi/tools/autobuild/default_hooks/setup.sh
export BUILDER_NODE="192.168.1.43"
export CATTLEPI_DEFAULT_S3_BUCKET="my-cattlepi-bucket"
cattlepi/tools/autobuild/build_and_publish.sh
```

You will need to set the **BUILDER_NODE** to point to the IP of your raspberry pi and the **CATTLEPI_DEFAULT_S3_BUCKET** to a S3 bucket your AWS credentials have access to. 

The [default hooks](https://github.com/cattlepi/cattlepi/blob/master/tools/autobuild/default_hooks/setup.sh) reset the builder node to a clean state between image builds.

[You can inspect the build_and_publish.sh script here](https://github.com/cattlepi/cattlepi/blob/master/tools/autobuild/build_and_publish.sh)

By default, images listed in the [recipes.txt](https://github.com/cattlepi/cattlepi/blob/master/tools/autobuild/recipes.txt) file are built.

For more details: see the PR that implemented this feature [here](https://github.com/cattlepi/cattlepi/pull/75) or see it in action in the harness that automatically builds the images that are periodically published [here](https://github.com/cattlepi/cattlepi-scratch/blob/master/buildonpi/autobuild.sh)
