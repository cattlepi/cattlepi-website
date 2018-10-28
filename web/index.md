---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

[cattlepi.com](https://cattlepi.com) is the documentation companion for the [CattlePi](https://github.com/cattlepi/cattlepi) project.

We recommend you go through the project [README](https://github.com/cattlepi/cattlepi/blob/master/README.md) as a first step. 

To run CattlePi you need three major pieces:
 * one of more Rasperry Pi devices
 * a backend API that stores the configuration for the Pi devices you want to control
 * image files that are used, both in the boot process, and as the root filesystem for the managed devices

When leveraging CattlePi, one can:
 * build and serve the images along with implementing the API
 * build and serve the images while leveraging a prebuilt API
 * leverage prebuilt images and a prebuilt API

 `api.cattlepi.com` provides a prebuilt API back-end and can also serve the standard image files.  
 You can use this api endpoint to configure your own devices. They can boot the standard images or you can point them to images that you've built on your own. 
 
 On the website you will find:
  * [HowTo]({% link howto.md %}): a series of posts that go in depth into cool projects and good cattlepi use cases
  * [Boot Flow]({% link flow.md %}): understand the boot flow and how the loader interacts with the API 
  * [Images]({% link images.md %}): a list of prebuilt images that you can use, out of the box, on your Rapsberry Pis
  * [Api]({% link api.md %}): a description of the API, and how to interact with it outside of the boot process

Our hope is that you'll find it useful and cattlepi will unlock scenarios that were impossible or hard to manage before.

**Your feedback is greatly appreciated.**
