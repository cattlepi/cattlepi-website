---
layout: post
title:  "Injecting Code via the BootCode"
excerpt_separator: <!--more-->
---
This post will help you understand how the bootcode field in the device boot configuration works. It's similarly to the usercode field we've played with in the [previous tutorial]({% post_url 2018-08-21-pihole-and-usercode %})

<!--more-->
So, how is the bootcode different from the usercode?  
One difference is that it's running in the boot phase, before the root filesystem is built and while the SD card is still in read/write more.  
The typical usecase for this would be to alter something in config.txt or cmdline.txt, but because of the stage this runs in, you can pretty much hijack the boot process however you like.  
You can see the code that handles the bootcode field [here](https://github.com/cattlepi/cattlepi/blob/b30645c02553a009ed961eb1c0f0b108fee4a460/templates/raspbian/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L130).  

For this tutorial we will update the amount of gpu memory we are allocating for our Pi. For a bit of background, for the Raspberry Pi, the memory is split between the CPU and the GPU. By default the GPU gets 64 megabytes, and the CPU gets what's left. More details here: [config-txt/memory.md](https://www.raspberrypi.org/documentation/configuration/config-txt/memory.md)  

On a Pi that with an factory config.txt let's look at how much memory the CPU has available:
```bash
pi@raspberrypi:~$ free -mt
              total        used        free      shared  buff/cache   available
Mem:            927          68         100         156         757         649
Swap:             0           0           0
Total:          927          68         100
pi@raspberrypi:~$ vcgencmd get_mem arm
arm=948M
pi@raspberrypi:~$ vcgencmd get_mem gpu
gpu=76M
```

In case you're wondering the disconnect between the number reported by free and the get_mem arm is normal. You can use dmesg to see available memory vs total memory (and things that get free later in the process).  


We're going to alter the **gpu_mem** option and set the memory the gpu uses to the minimum allowable (16).  
You can see a way to achieve this here: [mingpu.sh](https://github.com/cattlepi/cattlepi-samples/blob/074273edd6f37e5d99c99f5fe4fea2583ce84ee7/bootcode/mingpu.sh). It's pretty straighfoward with the trick being that the script can be executed on each boot and will only have any effect only if it wasn't run before.

Like we did in the case of the bootcode, we are going to configure the device boot configuration to retrieve and run this code. Remember that the bootcode is base64 encoded.

```bash
BOOTCODE=$(echo $(echo 'curl -sSL https://raw.githubusercontent.com/cattlepi/cattlepi-samples/master/bootcode/mingpu.sh | /bin/sh' | base64 -w 0))
PAYLOAD='{"bootcode":"'$BOOTCODE'","config":{"ssh":{"pi":{"authorized_keys":["'$(head -1 $HOME/.ssh/id_rsa.pub)'"]}}},"initfs":{"md5sum":"52a4b9c7be7850ce0d959244bfdee292", "url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/initramfs.tgz"},"rootfs":{"md5sum":"015615fdacb170c158ea5c20a959ceaf","url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/rootfs.sqsh"}}'
curl -vvv -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config
```

A small difference that you might notice is that instead of piping to bash we are piping to /bin/sh. Technically the environment we are running at the point not have a full bash shell, but it should be capable of executing this script. (if curious the shell is ash and it's brought in by busybox).

After changing the device config and rebooting, let's run the same command as before:
```bash
pi@raspberrypi:~$ free -mt
              total        used        free      shared  buff/cache   available
Mem:            976          54         129         165         792         702
Swap:             0           0           0
Total:          976          54         129
pi@raspberrypi:~$ vcgencmd get_mem arm
arm=998M
pi@raspberrypi:~$ vcgencmd get_mem gpu
gpu=16M
```

To sum up: we've written a small shell script that we've injected into the bootcode field. Upon boot, this script alters the memory made available to the GPU to 16M. Remember that this is a demo of the kind of things you can do by injecting code via the bootcode field as the device is booting. You are free to change anything that happens in the boot stage. 

If the script you want to use is buggy/needs work and your Pi crashes while it boots up, here are a few pointers to help you:  
**1)** attach a keyboard and a monitor to the Pi and use the *break=* kernel param as described here: https://wiki.debian.org/InitramfsDebug (you would put this in the cmdline.txt file)  
**2)**  another technique involves setting the *boot_delay=* kernel param (see https://www.kernel.org/doc/html/v4.14/admin-guide/kernel-parameters.html) This will allow you to slow down the boot to a point where you can observe things.  
**3)** Have your script log and/or have pauses in it for you to be able to better understand what's going on.

You can use any combination of the above or you can invent your own technique. Happy hacking.
