#!/bin/bash

set -ex

# start haproxy
sudo yum -y install haproxy
sudo /usr/sbin/haproxy -f /home/ec2-user/hosting/haproxy.conf -D

# start the blog and the reboot listener
docker run --restart=always -d -p 8080:8080 -p 8081:8081 gordonburgett/blog

uuid="30b96b9c-bff4-4f6b-a0fc-df88d045c8a2"
curl https://raw.githubusercontent.com/schickling/docker-hook/master/docker-hook > /home/ec2-user/hosting/docker-hook; chmod +x /home/ec2-user/hosting/docker-hook
nohup /home/ec2-user/hosting/docker-hook -t $uuid -c /bin/bash /home/ec2-user/hosting/update_container.sh &


# set up ecs
sudo mv ~/hosting/ecs.config /etc/ecs/ecs.config


# install squid proxy & configure
sudo yum -y install squid
sudo cp ~/hosting/squid.conf /etc/squid/squid.conf