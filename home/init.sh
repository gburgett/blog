#!/bin/bash

set -ex

# start haproxy
sudo yum -y install haproxy
sudo /usr/sbin/haproxy -f /home/ec2-user/hosting/haproxy.conf -D

# set up ecs
sudo mv ~/hosting/ecs.config /etc/ecs/ecs.config

# set up docker cloud
curl -Ls https://get.cloud.docker.com/ | sudo -H sh -s 595eca1a930246a7a6afb990abb019ba

# install squid proxy & configure
sudo yum -y install squid
sudo cp ~/hosting/squid.conf /etc/squid/squid.conf

# do an update which is running in the background while we've at least got things running
sudo yum update