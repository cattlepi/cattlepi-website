---
layout: post
title:  "Setting up Pi-Hole via the prebuilt image"
excerpt_separator: <!--more-->
---
In a [previous tutorial]({% post_url 2018-08-21-pihole-and-usercode %}) we learned how to setup our Raspberry Pi to run PiHole by injecting the setup code into the usercode that runs automatically on setup. While this is useful (and you should leverage the usercode when needed) it also has a few downsides: 
 * it's slow. the whole pihole process can take quite a long time. 
 * it's error prone. A network connectivity issue or any other transient issue (that may not be under your control) means that the pihole setup might fail .

 <!--more-->
 
Ideally we would want the PiHole to come up as fast and as reliable as possible.  
One of the great things about CattlePi is that you can build your own recipes and you can choose to customize the image that is going to run on the Pi however you want.  

We did exactly this for PiHole.  
The PiHole recipe for this is: [here](https://github.com/cattlepi/cattlepi/blob/master/recipes/raspbian_pihole.yml)  
To build it, do: [make raspbian_pihole](https://github.com/cattlepi/cattlepi/blob/master/Makefile#L25)

What does the recipe do?  
It's based on the raspbian_cattlepi recipe and it adds a few things: [the script](https://github.com/cattlepi/cattlepi/blob/master/templates/raspbian_pihole/resources/bin/build_pihole.sh) that bakes PiHole into the image at build time and [the script](https://github.com/cattlepi/cattlepi/blob/master/templates/raspbian_pihole/resources/bin/bootstrap_recipe.sh) that will update the ip and the interfaces on Pi startup.

The whole recipe is injected into the cattlepi base recipe via the [preclone_hook_squashfs.yml](https://github.com/cattlepi/cattlepi/blob/master/templates/raspbian_pihole/tasks/preclone_hook_squashfs.yml).

This hook is present in the cattlepi recipe, but [it does nothing in that context](https://github.com/cattlepi/cattlepi/blob/master/templates/raspbian_cattlepi/tasks/preclone_hook_squashfs.yml). When using the pihole recipe, the hook gets overwritten and we get the chance to invoke the logic we want without having to build the whole recipe from scratch (which is great because we avoid duplication).

Also, here is an example of device boot target configuration configuration that uses this recipe:
```json
{
  "bootcode": "",
  "config": {
    "autoupdate": true,
    "ssh": {
      "pi": {
        "authorized_keys": [
          "your ssh public key"
        ]
      }
    }
  },
  "initfs": {
    "md5sum": "fc9deaedfb0a2701138535f0878aa752",
    "url": "https://api.cattlepi.com/images/global/raspbian-pihole/2018-06-29/v8/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "e009a7ca757d32f6783745c50e9a2411",
    "url": "https://api.cattlepi.com/images/global/raspbian-pihole/2018-06-29/v8/rootfs.sqsh"
  },
  "usercode": ""
}
```

Find the latest image cattlepi pihole image info in the [Images]({% link images.md %}) section.
