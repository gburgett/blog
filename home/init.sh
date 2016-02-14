#!/bin/bash

set -ex

# set up ecs
sudo mv ~/hosting/ecs.config /etc/ecs/ecs.config

# set up docker cloud
curl -Ls https://get.cloud.docker.com/ | sudo -H sh -s 595eca1a930246a7a6afb990abb019ba

# install squid proxy & configure
sudo yum -y install squid
sudo cp ~/hosting/squid.conf /etc/squid/squid.conf