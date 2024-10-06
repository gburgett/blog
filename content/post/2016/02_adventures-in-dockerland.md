+++
Categories = ["Development"]
Description = ""
Tags = ["Development", "docker"]
date = "2016-02-20T20:33:52+01:00"
menu = "main"
title = "Adventures in Dockerland"
aliases = [
  "/post/adventures-in-dockerland/",
]

+++

I've been on a serious docker/aws kick recently.  I've learned just enough that it drives me to play with it.  I spent a lot of my free time on it this week, and didn't spend as much as I'd like on learning Albanian... This could be a problem...

Anyways I might as well post more about what I've learned.  I've been wanting to make my web server more robust, to where if it dies for whatever reason I don't have to do anything, it'll come back on a new instance all on its own.  Unfortunately that's a bit more difficult than you'd expect.  Lots of moving parts.

The first thing that I have to do manually whenever my server dies is change the DNS records.  So let's try to make that automatic.  AWS has it's own DNS service called Route53.  It lets you link all sorts of things, like load balancers and the like, and update it programmatically via the API.  So I migrated my DNS records over to Route53.

![Route53 Domain records](/images/2016/route53-dns.png)

Next I created an AWS Lambda function.  AWS Lambda lets you run NodeJS or Python programs on demand, based on any number of input events.  You don't have to worry at all about infrastructure, they charge based on resource usage and execution time.  I'm using it to automatically update my DNS records whenever my blog server dies & is restarted.

![AWS Lambda function](/images/2016/aws-lambda-config.png)

One "gotcha" that's not immediately apparent with AWS Lambda, is that if you need any extra nodejs libraries you have to pack them yourself.  Since I'm using the `async` and `https` libraries, I had to package the whole thing as a zip file including the `node_modules` folder.  Also, it runs an older version of nodejs, so you need to make sure you're developing on that version.

You can see my code here: https://github.com/gburgett/lambdas/blob/master/route53-asg-update/index.js

Through the boilerplate of the async calls, it's doing the following things:

```javascript
// look for the tag named "DomainMeta" on the AutoScalingGroup
 autoscaling.describeTags({ ... })l

// Parse that tag into the ID of the Route53 DNS records
 var tokens = response.Tags[0].Value.split(':');
 var route53Tags = {
  HostedZoneId: tokens[0],
  RecordName: tokens[1]
 };

// Get the IP addresses of all the active EC2 instances in the AutoScalingGroup
 autoscaling.describeAutoScalingGroups({ ... });
 ...
 ec2.describeInstances({ InstanceIds: instance_ids });
 ...
 var resource_records = ec2Response.Reservations.map(function(reservation) {
  return {
    Value: reservation.Instances[0].NetworkInterfaces[0].Association.PublicIp
  };
 });

// Change the DNS record in Route53 to point to these public IP addresses
 route53.changeResourceRecordSets({
  ChangeBatch: {
   Changes: [{
     Action: 'UPSERT',
     ResourceRecordSet: {
      Name: route53Tags.RecordName,
      Type: 'A',
      TTL: 10,
      ResourceRecords: resource_records
     }
    }]
  },
  HostedZoneId: route53Tags.HostedZoneId
 });
```

Now the last thing is to hook that up to the AutoScalingGroup's change events.  I used an AWS SNS topic to link the two.

![the SNS topic](/images/2016/aws-sns-topic.png)

![The Auto-Scaling group](/images/2016/aws-asg-notifications.png)

And now, whenever my instance dies, the DNS settings are automatically updated with the new instance's IP address!  There's just one problem though.  Docker cloud limits you to only 1 node for free.  It's $15/mo for each additional node.  If you try to bring online a second node when it thinks there's still one up, it sends you a [402 Payment Required](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#4xx_Client_Error).

To solve this, I just had to add to my lambda code something to notify the docker cloud API that my node has been terminated.  Normally, when a node dies, docker cloud calls it "unreachable" but doesn't give up on it.  However, when my lambda function gets an event, I know that the node is dead.  So I can make a call to the docker cloud API to tell it to terminate the node.

The relevant code is in the `updateDockerCloud` function.  Again stripping the boilerplate:

```javascript
// Get all my running nodes
 var req = https.request({ host: "cloud.docker.com", path: "/api/infra/v1/node/", method: "GET"});
...
// Find in the list all the nodes which Docker Cloud thinks are alive, but aren't.
 objs = objs.filter(function(o) 
    { return !resource_records.some(function(rr) {return rr.Value == o.public_ip;}); }
  );
  objs = objs.filter(function(o)
    { return o.state != "Terminated"; }
  );
  console.log("to terminate: " + JSON.stringify(objs));
...
// Send a delete request for each of those nodes.
 var req = https.request({
  host: "cloud.docker.com",
  path: "/api/infra/v1/node/" + o.uuid + "/",
  method: "DELETE"
 });
```

Once I included that in my Lambda function, the whole shebang goes off without a hitch.  I can kill my node, and my auto-scaling group fires up a new one within minutes.  Docker cloud then sees the new node, and deploys my containers to it.  Success!
