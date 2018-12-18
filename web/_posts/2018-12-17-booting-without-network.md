---
layout: post
title:  "Offline mode; or 'booting without the network'"
excerpt_separator: <!--more-->
---
Historically, the CattlePi project has been very dependent on network connectivity.  We require the network to contact the API in order to pull down config, images, etc.

However, what if you need to configure a Pi with custom software setup and config, but it needs to run without network connectivity? You're in luck! This is now supported by CattlePi! Just because your Pi needs to run off the network doesn't mean that you should have to manually configure it. "**Pet projects into cattle projects**", remember?

<!--more-->

Ok, so we fibbed just a tiny bit. Your Pi needs network connectivity **once**, just to provision it with the image you have configured. Once provisioned, you can boot and run without the network!

There's nothing particularly magic about this functionality, and very little in the way of setup. In order for the Pi to function properly with your carefully curated image, it must first complete the entire CattlePi provisioning process which includes pulling down the config and the proper images.

_Once the Pi has a valid config, and images that match the config, it will function without the network_

The steps are as follows:
* Setup and build your image CattlePi initramfs and root image as normal.
* Write the initramfs to your SD card using [etcher](https://etcher.io/) or a similar tool.
* Boot the Pi and allow it to complete the CattlePi provisioning process entirely. (The process will end when booted into your image and sitting at a login prompt)
* You may now operate the Pi without network!

The PR that implemented this feature is [here](https://github.com/cattlepi/cattlepi/pull/44).

The code checks for API connectivity. If it is unable to contact the API, it ensures that a valid config file exists and that the `rootfs` image md5sum matches the config. Provided this all works, the Pi boots in "offline mode", skipping any attempts to do any CattlePi network functionality!

As always, we welcome any and all feedback.  Please [open an issue](https://github.com/cattlepi/cattlepi/issues) for any issues/comments/suggestions.
