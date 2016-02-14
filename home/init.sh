#!/bin/bash

set -ex

sudo apt-get update

# set up docker cloud
sudo apt-get -y install python-pip
sudo pip install docker-cloud
docker-cloud node byo | grep 'curl' | sh

# install squid proxy & configure
sudo apt-get -y install squid
sudo cp ~/hosting/squid.conf /etc/squid/squid.conf