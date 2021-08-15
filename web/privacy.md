---
layout: page
title: Privacy
permalink: /privacy/
---

These terms apply to the content on this website (**cattlepi.com**) and the API service that this website references (**api.cattlepi.com**).  

The website does not use any kind of cookies.  
We do leverage AWS Cloudfront for the purpose of serving this website. See Web Distribution Log File Format [here](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html) to understand the type of information CloudFront captures on each request. Among other things, your IP, referrer, user-agent, query url, the CloudFront location that served the request, etc are things that are captured and used by CloudFront to generate analytics. We **do not** have logging explicitly enabled on CloudFront so apart from analytics that give us a rough idea on the sources of the traffic and traffic volume we don't know (or want to know) anything about you.

The api service (api.cattlepi.com) captures and logs all the requests it receives (headers and body). This is done solely for the purpose of troubleshooting if the need ever arises. The logs retention period is 60 days from the moment they are generated.  

The api also captures and stores internally information that you provide about your devices including, but not limited to the device ids, boot configurations, startup scripts, etc. Basically everything that you provide to the api is preserved. Data provided by you is only accessible by you, unless you explicitly specify it otherwise. 

Requesting an api key (as described in the api section) will require an email address. 
We will remember this email address and use it to contact you only in one of two following cases:  
 * to let you know we are discontinuing this service (hopefully never)
 * abusive behavior is detected from usage of your api key (again hopefully never)  

We do not share your email address with any third party and we will never send you an unsolicited email except for the two cases above.

You do have the option of requesting that we do not retain your email in our database and we will honor your request without any questions if you agree to the fact that we will not be able to reach you in the situations outlined above and that this will result in the deactivation of your api key.  

You also have the option of requesting that we remove all the entries associated with your api key from our database. We will also honor this request without any kind of questions or pushback. This will lead to deactivation of the api key and we will typically process the request within a week.  

Your privacy is really important to us. The only thing that really matters to us is that you find the service useful. 