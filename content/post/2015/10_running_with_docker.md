+++
Categories = ["Development", "Hosting"]
Description = ""
Tags = ["Development", "docker", "hosting"]
date = "2015-10-07T20:33:41+02:00"
menu = "main"
title = "Running with Docker"
aliases = [
  "/post/running_with_docker/",
]

+++

### Locked out!

I managed to lock myself out of my EC2 instance when I was managing my keys.  So in order to update my blog, I had to deploy it to a new EC2 instance.  I decided to take the opportunity to improve the way I'm deploying new versions of my site.

Note: This will be a technical post.  If you're following along with my adventure in Albania, you can skip this one.

### Docker, for fun and profit

[Docker](https://www.docker.com/) is a program which manages "containers".  A container is it's own isolated system inside a running Linux operating system, separated from other containers and from the main entry point.  Docker runs containers from "images", which contain all the files, programs, and settings necessary for the main program in a container.  It's similar to a lightweight virtual machine.

I was able to use this to pre-package the environment necessary to run my server.  Instead of having to remember how to set up nodeJs, install the npm packages, and run the server, I encoded that in my Dockerfile.  The Dockerfile contains instructions to build docker containers.

```dockerfile
# Use centos7 as a base for my docker container
FROM centos:centos7

# Enable EPEL to get Node.js
RUN yum install -y epel-release
# Install Node.js and npm
RUN yum install -y nodejs npm

# Install hugo
RUN curl -L -o /tmp/hugo.tar.gz https://github.com/spf13/hugo/releases/download/v0.14/hugo_0.14_linux_386.tar.gz
RUN tar xvf /tmp/hugo.tar.gz -C /tmp/
RUN mv /tmp/hugo_0.14_linux_386/hugo_0.14_linux_386 /usr/bin/hugo

# Add my npm modules
COPY package.json /src/package.json
RUN cd /src; npm install

# Expose ports 8080 and 8081 to outside the docker container
EXPOSE 8080 8081

# Set the command to be executed when the docker container is run.
CMD ["node", "/src/node/server.js", "/src/public", "8080", "8081"]

# Copy my blog into the /src directory and generate the blog output with Hugo
COPY ./ /src/
RUN hugo -s /src/ --baseUrl="http://www.gordonburgett.net"
```

Now I can run it anywhere that has Docker, and I don't need to worry about installing all my dependencies.  They're all already baked in to the image.

I created a repository on [Dockerhub](https://hub.docker.com/r/gordonburgett/blog/) to host my images, so that I can easily pull them down with the web server.  Dockerhub has easy integration with Github - all you have to do is link your accounts and you can set up an automatic build whenever you push your code.  It also has webhooks - whenever a build completes, it will send a message to any URL you provide.  I'm using that to build a chain of tools to automatically deploy my blog whenever I push a new version to Github.

### Launching the new server

I went to AWS console and fired up a new EC2 instance, using my existing key pair.  I decided this time to track everything I did and keep it in a shell script to make it easy to set up a new instance anytime I need.  I shouldn't treat my web server like a pet, it's easier to treat it like a head of cattle.  When a pet gets sick, you spend a lot of time and effort to nurse it back to health.  When a cow gets sick, you slaughter it and buy a new cow.

My init script looks like this (after much trial and error):

```bash
#!/bin/bash

set -e

# Read command line parameters ( -i /path/to/identity.pem )
identity=""
while getopts i: opt; do
  case $opt in 
  	i)
		identity="-i $OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
  esac
  shift $((OPTIND-1))
done

server=$1
[[ -z "$server" ]] && echo "expected server address" && exit -1

# send over all the files in the "hosting/" folder, including the SSL cert & private key.
rsync -avz -e "ssh $identity" hosting/ ec2-user@$server:~/hosting

# SSH in to the server and run these commands to configure it:
pubkey=`cat ~/.ssh/id_rsa.pub`

init="chmod -R 0700 ~/hosting
echo \"$pubkey\" >> ~/.ssh/authorized_keys	# Add my key to the authorized key list

# Install haproxy and docker
sudo yum -y install haproxy docker

# Configure and start docker
sudo groupadd docker
sudo gpasswd -a ec2-user docker
sudo service docker start

# Finally, start haproxy with the synced config file.
sudo /usr/sbin/haproxy -f /home/ec2-user/hosting/haproxy.conf -D"
ssh -t $identity ec2-user@$server "$init"

# log out to join the docker group, then ssh back in to start the docker container.
uuid=`uuidgen`
run="docker run --restart=always -d -p 8080:8080 -p 8081:8081 gordonburgett/blog || echo \"already running\"

# Install docker-hook, a small python web listener which
# restarts docker when it receives a message from Dockerhub.
curl https://raw.githubusercontent.com/schickling/docker-hook/master/docker-hook > /home/ec2-user/hosting/docker-hook; chmod +x /home/ec2-user/hosting/docker-hook
nohup /home/ec2-user/hosting/docker-hook -t $uuid -c /bin/bash /home/ec2-user/hosting/update_container.sh &"
ssh -t ec2-user@$server "$run"

echo "Add this to dockerhub hook:"
echo "http://www.gordonburgett.net:8555/$uuid"
```

I ran that script against a fresh EC2 instance and it fired up my blog!  Also, every time I make a new post, I only have to upload it to Github and it's automatically deployed to my web server in less than 10 minutes.  Success!

### Hooking up automatic notifications

I'm using MailChimp to manage my email list for my newsletter.  It has a ton of great features, even on the free account.  One is an automatic campaign which is sent out based on an RSS feed.  This is perfect for updating users whenever I post a new blog entry.

I created a sub-section of my subscribers list based on whether they had opted out of receiving blog updates.  There's a new radio dial on the sign-up form that looks like this:

<div>
  <link href="//cdn-images.mailchimp.com/embedcode/classic-081711.css" rel="stylesheet" type="text/css">
  <style type="text/css">
  #mc_embed_signup{background:#fff; clear:left; font:14px Helvetica,Arial,sans-serif; }
   
  </style>
  <div id="mc_embed_signup">
    <form name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate="novalidate">
      <div id="mc_embed_signup_scroll">
        <div class="mc-field-group input-group">
          <strong>When my blog is updated: </strong>
          <ul>
            <li><input value="Get an email" name="BLOGUPDATE" id="mce-BLOGUPDATE-0" type="radio"><label for="mce-BLOGUPDATE-0">Get an email</label></li>
            <li><input value="Don't send anything" name="BLOGUPDATE" id="mce-BLOGUPDATE-1" type="radio"><label for="mce-BLOGUPDATE-1">Don't send anything</label></li>
          </ul>
        </div>
      </div>
    </form>
  </div>
</div>

I set up an automatic campaign to send an email with the content of my most recent blog posts.  It checks the RSS feed [here](/index.xml) every day at 4am eastern time, and if there's a new post, it sends a message and also posts for me on facebook.  Neat, eh?

![Mailchimp RSS example](/images/2015/mailchimp_rss_example.640x.png)

Well, that's it for this adventure in useless stuff I didn't really need to do but had fun doing.  See you next time, technical readers!