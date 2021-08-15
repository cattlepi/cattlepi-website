---
layout: post
title:  "Wireless functionality"
excerpt_separator: <!--more-->
---
One of the great things about the Raspberry Pi 3 is its ability to use a wireless network connection, removing the need for extra cables. Up until now, Raspberry Pis provisioned with CattlePi have required a hardwired network connection. You may have even tried to hack around this by including a `wpa_supplicant` in your rootfs or other methods.

Wireless functionality is now a fully supported CattlePi feature! Once the proper key is setup in the config, and your CattlePi is fully provisioned, it will connect to the wireless network to do its business.

<!--more-->

You need a few things setup for this all to work properly:
* A valid `wpa_supplicant.conf` file that is base64 encoded (just as we do with the usercode).  An example of said file is below. See the [Raspberry Pi docs here](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) for more info.  **Make sure you set your country code in the file per the documentation!**
* The config for your pi must have a config key `wpa_supplicant`. The key contains the base64 encoded `wpa_supplicant` file. (Example below)

Putting this all together is straightforward. Create a file `wpa_supplicant.conf` that looks like the following, substituting your details:

```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
        ssid="cool_wireless_ssid"
        psk="REDACTED"
        key_mgmt=WPA-PSK
}
```

Then we'll base64 encode the file:
```bash
cat wpa_supplicant.conf | base64 -w 0
```

This will give us a long string of characters. This long string is what will live in our config file under the key `config.wpa_supplicant`. See the sample below.

```json
{
  "config": {
    "wpa_supplicant": "Awholebunchofbase64encodeddata",
    ...
  }
...
}
```

We'll POST this config file to the API, allowing us to use it for future builds. 

```bash
PAYLOAD='{...,"config":{"wpa_supplicant": "your-base-64-encoded-wpa_supplicant",...}}'

curl -vvv -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: yourcoolapikey" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config
```

To verify that we POST-ed the correct config:

```bash
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: yourcoolapikey" \
    https://api.cattlepi.com/boot/default/config | jq -r .config.wpa_supplicant | base64 -d
```

Now we should be able to fully provision our Pi.  Let the Pi go through the entire CattlePi provisioning process, until it is sitting at a login prompt. Even with proper wireless config, a fully booted `raspbian_cattlepi` machine that has an Ethernet cable plugged into it will give precedence to the hardwired network. At this point, you can reboot the machine, pull the Ethernet cable, and function wirelessly from this point forward!

It is important to mention that you are welcome to update the `wpa_supplicant` data in the config at any time. If the Pi is booting and picks up a config file with updated `wpa_supplicant` data, it will reboot and use this new config data. You may also add multiple networks to the file if you know that you will be moving the Pi around to different places. The [Raspberry Pi docs](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on this are really great (multiple network config is towards the bottom of the page).

The PR that implemented this feature is [here](https://github.com/cattlepi/cattlepi/pull/72).

As always, we welcome any and all feedback.  Please [open an issue](https://github.com/cattlepi/cattlepi/issues) for any issues/comments/suggestions.


