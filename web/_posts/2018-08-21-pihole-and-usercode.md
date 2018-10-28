---
layout: post
title:  "Setting up Pi-Hole via usercode"
excerpt_separator: <!--more-->
---
This post will help you understand how the usercode field in the device boot configuration works. In the process of demostrating how this works, we will also show you how you could setup Pi-Hole by using this feature.

<!--more-->
We assume that you've already gone through the [Hello CattlePi Tutorial]({% post_url 2018-08-10-hello-cattlepi %}) and have your account and default boot target config. 

**First thing** first: What is Pi-Hole? You can check out the [project on its official page](https://pi-hole.net/) or on its [wikipedia page](https://en.wikipedia.org/wiki/Pi-hole). In a nutshell, it's a DNS sinkhole that sits between you and the real DNS servers and selectively blacklists domains known to be used by ad networks. The net effect of this is that you will not see ads originating on those subdomains (and a nice side effect is that you will experience faster browsing speeds).  

Pi-Hole is an extermely efficient way of leveraging a Raspberry Pi to do network level ad-blocking in your home network. You setup the Pi, you configure the router to use its IP as the DNS server and you're mostly done.  

**Second**: What is usercode?  
Let's take another look at device boot config.  
```json
{
  "bootcode": "",
  "config": {},
  "initfs": {
    "md5sum": "52a4b9c7be7850ce0d959244bfdee292",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/initramfs.tgz"
  },
  "rootfs": {
    "md5sum": "015615fdacb170c158ea5c20a959ceaf",
    "url": "https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/rootfs.sqsh"
  },
  "usercode": ""
}
```
It turns out that you can use the **usercode** field to pass in a script that your Raspberry Pi will run once the boot process is finished. You can see the code here that does this [here](https://github.com/cattlepi/cattlepi/blob/37a3646ead437cd8d3765ffcec8fe45086e4567c/templates/raspbian/resources/bin/bootstrap.sh#L26)  
You can see the bootstrap being inserted in rc.local [right before the end of it](https://github.com/cattlepi/cattlepi/blob/b30645c02553a009ed961eb1c0f0b108fee4a460/templates/raspbian/tasks/squashfs.yml#L23)  

How does a script that you can insert in there look like? It's any script you want with the caveats that 1) you have to base64 encode it 2) for api.cattlepi.com the maximum body size of any request is 4096 (this includes everything in the json, so your script is probably less than this). It may seem like a big limitation, but in reality your script could download (from another location) and execute a script of any size - so you can work around this limitation pretty easily.  

Now, to put the 2 together. We want to write a script that performs an unattended Pi-Hole install via the usercode.  
You can one way of doing this here: 
[https://github.com/cattlepi/cattlepi-samples/blob/master/pihole-via-usercode/piholeup.sh](https://github.com/cattlepi/cattlepi-samples/blob/master/pihole-via-usercode/piholeup.sh)

The code is pretty self explanatory. It generates 2 configuration files needed by the Pi-Hole install and after that it triggers the Pi-Hole unattended install.  
If we were to run this manually we would do (using root or sudo) something like this:
```bash
curl -sSL https://raw.githubusercontent.com/cattlepi/cattlepi-samples/master/pihole-via-usercode/piholeup.sh | bash
```

What we're going to do is base64 encode this and put in in the usercode field in the boot device config.
```bash
USERCODE=$(echo $(echo 'curl -sSL https://raw.githubusercontent.com/cattlepi/cattlepi-samples/master/pihole-via-usercode/piholeup.sh | bash' | base64 -w 0))
PAYLOAD='{"usercode":"'$USERCODE'","config":{"ssh":{"pi":{"authorized_keys":["'$(head -1 $HOME/.ssh/id_rsa.pub)'"]}}},"initfs":{"md5sum":"52a4b9c7be7850ce0d959244bfdee292", "url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/initramfs.tgz"},"rootfs":{"md5sum":"015615fdacb170c158ea5c20a959ceaf","url":"https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v5/rootfs.sqsh"}}'
curl -vvv -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    -X POST -d "$PAYLOAD" \
    https://api.cattlepi.com/boot/default/config
```

To verify the device config we can do:
```bash
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    https://api.cattlepi.com/boot/default/config | jq .
```

To verify that the usercode was properly encodede we can do:
```bash
curl -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: 8db071a4-63ef-47f7-9cfc-ca479b5422da" \
    https://api.cattlepi.com/boot/default/config | jq -r .usercode | base64 -d
```
The output should match the command above: 
```bash
curl -sSL https://raw.githubusercontent.com/cattlepi/cattlepi-samples/master/pihole-via-usercode/piholeup.sh | bash
```

Let's now boot a Pi configured to use out API key.  
If you connect to the Pi you can also watch the progress by tailing /tmp/bootstrap.log

After the process is done, you should be able to load the Pi-Hole web interface by going to **http://192.168.1.87/admin/** (make sure to replace 192.168.1.87 with your own Pi IP). In case you're wondering *WEBPASSWORD=4b20c060f40545f80ab87081c3c91842b8c30a2ea7c9b2f4ee9094b70c96fd61* that was [setup](https://github.com/cattlepi/cattlepi-samples/blob/master/pihole-via-usercode/piholeup.sh#L52) by the installation script is actually a hash of the password **newpassword**. To make a long story short here is how this was generated: 
```bash
echo -n newpassword | sha256sum | awk '{printf "%s",$1 }' | sha256sum | cut -d ' ' -f 1
4b20c060f40545f80ab87081c3c91842b8c30a2ea7c9b2f4ee9094b70c96fd61
```
Remember this is just a demo, and you should probably replace this with your own password and maybe place the script on a host that you control. 

For completeness, let's also check that the Pi-Hole is resolving other DNS names:
```bash
dig +short cattlepi.com @192.168.1.87
52.84.16.11
52.84.16.64
52.84.16.54
52.84.16.117
```
Success! You should also see the query in the query log web interface.

The only thing left to do is to point update the DNS entries your router provides to point to your CattlePi-enabled Pi-Hole Raspberry Pi.  
You've now seen how to inject your own scripts that run in the Pi bootstrap process.  
