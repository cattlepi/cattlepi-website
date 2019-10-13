---
layout: page
title: Api
permalink: /api/
---
The following specifies how the external endpoint should behave if you want it to work out of the box with CattlePi. To make it easier we refer to the endpoint as `https://api.cattlepi.com`, but you can run the api wherever you would like. Be sure to update this in the configuration file as described [here](https://github.com/cattlepi/cattlepi/blob/07e384e17c3af7261ac3b075dfbd58408d849f85/doc/BUILDING.md#step-9---update-the-configuration-with-your-values)

The API accepts `JSON` and produces `JSON`. All examples here use `curl` to show interactions with the API.  

## API Keys

All requests to the API should be accompanied by an API key. Requests without an API key will fail with a `400 Bad Request` response status.  

**The key must be passed in a header named 'X-Api-Key'**

All the following examples use the demo `deadbeef` API key.  

Example request:
```bash
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "X-Api-Key: deadbeef" \
     https://api.cattlepi.com/boot/testid/config
```

The corresponding response would be:
```json
{
  "initfs": {
    "url": "https://api.cattlepi.com/images/global/initramfs.tgz",
    "md5sum": "93a4eccacabdcce8eb5b8b68de6742cc"
  },
  "rootfs": {
    "url": "https://api.cattlepi.com/images/global/rootfs.sqsh",
    "md5sum": "c1d44c65d29af575b2f6685b6a91d2da"
  },
  "bootcode": "",
  "usercode": ""
}
```
## API Operations

### https://api.cattlepi.com/boot/{deviceid}/config
+ **`GET`**  
  This call is used to retrieve the boot configuration associated with a device.  

  **A note on isolation**: two users (i.e. different API keys) can have the same deviceid without experiencing a collision. The device ids live in the scope of the API key and there is no way of accessing the device configuration of another user if you don't know the API key. 

  Example:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/boot/testid/config
  ```
  with response: 
  ```json
  {
    "initfs": {
      "url": "https://api.cattlepi.com/images/global/initramfs.tgz",
      "md5sum": "93a4eccacabdcce8eb5b8b68de6742cc"
    },
    "rootfs": {
      "url": "https://api.cattlepi.com/images/global/rootfs.sqsh",
      "md5sum": "c1d44c65d29af575b2f6685b6a91d2da"
    },
    "bootcode": "",
    "usercode": ""
  }
  ```

  **A note on a special deviceid**: The device id **`default`** is a special id. Whenever you do a get with a deviceid that was not specified before (through a previous POST for that device id), if a device configuration was specified for the `default` deviceid, you will receive this configuration. **Why?** This allows you to dynamically boot your devices without having to specify them a priori. You can maintain one device configuration for all your devices, or you can use the default one as a method of discovering and configuring them.  

+ **`POST`**  
  This call is used to update the boot configuration associated with a device.

  Example:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      -X POST -d '{"rootfs":{"url":"https://api.cattlepi.com/images/global/rootfs.sqsh","md5sum":"c1d44c65d29af575b2f6685b6a91d2da"},"initfs":{"url":"https://api.cattlepi.com/images/global/initramfs.tgz","md5sum":"93a4eccacabdcce8eb5b8b68de6742cc"}}' \
      https://api.cattlepi.com/boot/otherdevice/config
  ```

  A successful response would be:
  ```json
  {"status":"ok"}
  ```

  The structure of the json that is passed in is as follows:
  ```
    {
      "initfs": {
        "url": <<path to the initfs image : string>>,
        "md5sum": <<md5 sum of the initfs image : string>>
      },
      "rootfs": {
        "url": <<path to the rootfs image : string>>,
        "md5sum": <<md5 sum of the rootfs image : string>>
      },
      "bootcode": <<base64 encoded shell script : string >>,
      "usercode": <<base64 encoded shell script : string >>,
      "config": <<additional free form configuration : valid json>>
    }
  ```
  The API will **ignore** any keys that do not match the above. Any keys that are not specified will be set to an empty string (or empty json in case of the config)

  **Another note on isolation**: The demo API key `deadbeef` has this method disabled. Your individually requested key will not have this limitation.

+ **`DELETE`**  
  This call is used to remove the boot configuration associated with a device.

### https://api.cattlepi.com/images/{space}/filename
+ **`GET`**  
  Used to download images hosted by api.cattlepi.com
  The only valid values for the {space} path parameter are: `global` and the user's API key.

  Example request:
  ```bash
  curl -v -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/images/global/initramfs.tgz
  ```

### https://api.cattlepi.com/track
Tracking allows to retrieve information your devices have reported and to identify devices that are active on the network. A device is considered active if it was seen within the last 3 months.  

+ **`GET`**  
  Used to get a list of all your devices
  Example request:
  ```bash
    curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/track  
  ```
  A sample response:
  ```bash
  ["b8:27:eb:6c:33:e2","default"]
  ```

### https://api.cattlepi.com/track/{deviceid}
+ **`GET`**  
  Used to get the log entries associated with a device
  Example request:
  ```bash
    curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/track/b8:27:eb:6c:33:e2
  ```
  A sample response:
  ```bash
  [
    "2018-08-05 03:23:37.625624 BOOT GET",
    "2018-08-05 04:38:28.549549 BOOT GET"
  ]
  ```

+ **`POST`**  
  Used to add a new log entry for the specified device.   
  Example request:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      -X POST -d '{"info":"the bird is the word"}' \
      https://api.cattlepi.com/track/b8:27:eb:6c:33:e2
  ```
  With a sample response of:
  ```bash
  {"status": "ok"}
  ```

  After the update, a GET on `https://api.cattlepi.com/track/b8:27:eb:6c:33:e2` would result in 
  ```bash
    [
      "2018-08-05 03:23:37.625624 BOOT GET",
      "2018-08-05 04:38:28.549549 BOOT GET",
      "2018-08-05 04:46:41.767841 the bird is the word"
    ]
  ```

  Please notice the timestamp (UTC) that was automatically added. The timestamp also counts towards the 256 character limit. Also notice that the tracking information is append only (i.e. you cannot delete from it)
