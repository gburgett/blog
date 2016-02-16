#!/bin/bash

set -ex

sudo apt-get update

# set up docker cloud
sudo apt-get -y install python-pip jq
export DOCKERCLOUD_USER=gordonburgett
export DOCKERCLOUD_APIKEY=bcd3f047-7f81-46cf-af4c-f3de5963f467
sudo pip install docker-cloud
docker-cloud node byo | grep 'curl' | sh
sudo gpasswd -a ubuntu docker

# install squid proxy & configure
sudo apt-get -y install squid
sudo cp ~/hosting/squid.conf /etc/squid3/squid.conf