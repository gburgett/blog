#!/bin/bash

set -ex

sudo apt-get update

# install squid proxy & configure
sudo apt-get -y install squid
sudo cp ~/hosting/squid.conf /etc/squid3/squid.conf
sudo service squid3 stop

# set up docker cloud
sudo apt-get -y install python-pip jq
export DOCKERCLOUD_USER=gordonburgett
export DOCKERCLOUD_APIKEY=bcd3f047-7f81-46cf-af4c-f3de5963f467
sudo pip install docker-cloud
docker-cloud node byo | grep 'curl' | sh
sudo gpasswd -a ubuntu docker

# set up stats logging
$ sudo apt-get -y install libwww-perl libdatetime-perl
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -o ~/CloudWatchMonitoringScripts-1.2.1.zip
unzip ~/CloudWatchMonitoringScripts-1.2.1.zip -d ~/
rm ~/CloudWatchMonitoringScripts-1.2.1.zip
echo '*/5 * * * * ubuntu /home/ubunt u/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --swap-util --sw ap-used --disk-space-util --disk-space-used --disk-path=/ --auto-scaling=only --from-cron' | sudo  tee /etc/cron.d/metrics > /dev/null