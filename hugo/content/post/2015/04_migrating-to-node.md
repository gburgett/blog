+++
Categories = ["Development", "hosting"]
Description = "My experience migrating my blog to nodejs"
Tags = ["Development", "node", "expressjs", "hosting"]
date = "2015-04-10T23:23:19-05:00"
menu = "main"
title = "Migrating to Node"
aliases = [
  "/post/migrating-to-node/",
]

+++

## So I wanted an app server.

How hard could it be right?  Well, not really that hard at all.  

I was tired of having a static site served by apache.  I want to do some cool stuff with the google APIs, like maybe a form submit where the results end up in a google doc for me.  To do that I need more than hugo's static site generation.  But I didn't want to get rid of hugo because I like a lot of it's features, so I added nodejs on top of it as the application server.

It really wasn't hard to set up.  The most difficult part is thinking through the deployment package.  I decided my .js files will be inside a special `/node` directory inside `static`, so hugo will copy them as-is into the output directory `/public`.  The public directory then looks like this after hugo generates the site:

<pre>
public/
  | -- node
  |     | -- server.js
  |
  | -- index.html
  | -- 404.html
  | -- etc...
</pre>

As it turns out, its pretty easy to set up a web server on node.  I installed a basic web framework called [express](http://expressjs.com/) and I was off and running with a 25 line .js file:

```javascript
#!/usr/bin/env node

port = 80
if(process.argv.length > 2){
	port = parseInt(process.argv[2])
}

var express = require('express')

var app = express()

	//hide everything in the node folder
app.use('/node', function (req, res, next) {
  res.status(404).sendFile('404.html', {root: process.cwd()});
})

app.use(express.static('.'))


app.use(function(req, res, next) {
  res.status(404).sendFile('404.html', {root: process.cwd()});
});

console.log('listening on port ' + port)
app.listen(port)
```

The big deal is the three `app.use(` statements in the middle.  The first one hides the /node folder, intercepting any requests and returning a 404 so noone can see the code running my site (important for later when I add fancy things).  The second serves up my whole static site.  It would serve up my js files too if not for the first one.  The third is a 404 handler which responds with my 404.html web page.

Running it on the actual server box should be easy enough as well.  First I had to go install node, using instructions found [here](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-and-fedora).  Then I was able to install express using npm.

I put the blog content in ~/blog, and can serve it up from there with `sudo node node/server.js`.  One important piece was where to put the node_modules directory.  I moved it to `~/node_modules`, so it's not served up by the static site server, and node can find it there just fine.

Now, I don't want to start the server with sudo every time, because I want the app to run as ec2-user and not as root.  Now that it's no longer just a static site I need to be more worried about security.  Unfortunately ec2-user can't bind to port 80, so I had to do an IPTABLES redirect:  
`iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080`  
now I can start up the server on 8080 as a normal user, and it all works great:  
`node node/server.js 8080`

One last thing, I want to set up an automated process to monitor my server and reload whenever I upload changes.  I'm using [pm2](https://github.com/Unitech/pm2) which is a pretty nifty tool:    
`pm2 start node/server.js --watch -- 8080`

And I can see the list of running prcesses with `pm2 list`, and see details of my server process with `pm2 show server`.  With the "--watch" flag, it automatically detects changes to my files and restarts the process.  I didn't even really have to change my deploy script!

![pm2 list and show](/images/pm2-list-show.png)  
`pm2 monit`:
![pm2 monitoring](/images/pm2-monitoring.png)

Well, all that was fun.  Now I have the capability through node.js to add more fun features to my blog in the future.  Who knows what crazy things I'll fire up on that thing next?