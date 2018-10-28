---
layout: post
title:  "Autoupdating (Images/Configuration)"
excerpt_separator: <!--more-->
---
The device boot configuration supports specifying a boolean autoupdate flag. When set to true, a cronjob injected into the image will monitor the api for configuration changes and will reboot the device whenever a change is detected. Upon reboot the device will pick up and use the new configuration.  

<!--more-->

For our account (you'll need to use your own api key to actually have this work) let's inspect the current device boot configuration:
```bash
curl -fsSL -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" https://api.cattlepi.com/boot/default/config | jq .
{
  "bootcode": "",
  "config": {
    "ssh": {
      "pi": {
        "authorized_keys": [
            "ssh-rsa actual_base64_encodedkey email@test.com"
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

Now, let's add the autoupdate flag:
```bash
PAYLOAD='{"config":{"autoupdate":"true","ssh":{"pi":{"authorized_keys":["'$(head -1 $HOME/.ssh/id_rsa.pub)'"]}}},"initfs":{"md5sum":"aac02886e82573e19d1f3ecf62a9f760","url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v7/initramfs.tgz"},"rootfs":{"md5sum": "e43fe03f9fb64f8814904e76990d4104","url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v7/rootfs.sqsh"}}'
curl -vvv -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config
```

Now the device is configured to autoupdate. Because it was not before we will need to reboot it for it to become aware of the configuration and to monitor it from now on. 

The configuration is now:
```bash
{
  "bootcode": "",
  "config": {
    "autoupdate": "true",
    "ssh": {
      "pi": {
        "authorized_keys": [
            "ssh-rsa actual_base64_encodedkey email@test.com"
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

From this point on, any change you do to the configuration will trigger a device reboot. This is useful in the case that you want to update the images used, update the keys used or any tweak to the configuration.

Full details on how this works in [the PR that implements it](https://github.com/cattlepi/cattlepi/pull/25)
