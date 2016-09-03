#!/bin/bash

set -ex

cd /home/ubuntu
sudo apt-get update

# set up docker cloud
sudo apt-get -y install python-pip jq
export DOCKERCLOUD_USER=gordonburgett
export DOCKERCLOUD_APIKEY=****
sudo pip install docker-cloud
docker-cloud node byo | grep 'curl' | sh
sudo gpasswd -a ubuntu docker

# set up stats logging
sudo apt-get -y install libwww-perl libdatetime-perl
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -o ~/CloudWatchMonitoringScripts-1.2.1.zip
unzip ~/CloudWatchMonitoringScripts-1.2.1.zip -d ~/
rm ~/CloudWatchMonitoringScripts-1.2.1.zip
echo '*/5 * * * * ubuntu /home/ubuntu/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --swap-util --swap-used --disk-space-util --disk-space-used --disk-path=/ --auto-scaling=only --from-cron' | sudo tee /etc/cron.d/metrics > /dev/null

# set up backup job
chmod +x /home/ubuntu/backup.sh
echo '0 * * * * ubuntu /home/ubuntu/backup.sh >> /home/ubuntu/backup.log' | sudo tee /etc/cron.d/backup > /dev/null 


# download mosh and other utils
sudo apt-get -y install mosh

