---
layout: post
title:  "sunsetting https://api.cattlepi.com"
excerpt_separator: <!--more-->
---

We have an important announcement: we are sunsetting [https://api.cattlepi.com](https://api.cattlepi.com) - the CattlePi managed API.

The timeline is as follows: 
- starting today Oct 6 2019 we will no longer provide new API keys
- starting on Nov 1st 2019 the API will go into readonly mode - if you have an API key you will still be able to read/use the configuration for your devices but not upload new configurations
- starting on Dec 1st 2019 the API will go away completely. You may still be able to hit the endpoint for a while but the API key will stop working.

<!--more-->

# FAQ  
Q: Why are you sunsetting the API?  
A: The API was meant as a way to quickly get up and running and having to worry only about the RPis and not the external endpoint that CattlePi uses. That being said, this came with the caveat that your configurations now lived on an external service - this was okay for some people but we just didn't see a lot of traction in the area that would justify the continuous investment in maintaining and running the API.  

Q: What does that mean for CattlePi as a project?  
A: It has almost no impact. You are still free (as you were before) to setup your own API server. You can just run https://github.com/cattlepi/cattlepi/blob/master/server/server.py locally, setup something like nginx that serves static files or even write your own API implementation. We're going to maintain the contract for the API calls described here https://cattlepi.com/api/ in a backwards compatible manner so that if you decide to write your own implementation it will just work with CattlePi out of the box (minus of course configuring where the endpoint is)  

Q: I am actively using the API for "insert your project here". Can you keep it up and running?  
A: The general answer is no - the managed API is going away. That being said, do go ahead and email us at the contact address on cattlepi.com and we will do our best to help you.   
