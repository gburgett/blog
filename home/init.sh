#!/bin/bash

set -ex

cd /home/ubuntu
sudo apt-get update
sudo apt-get -y install python-pip jq

# get AWS info
export INSTANCE_ID=$(curl -s http://instance-data/latest/meta-data/instance-id)
export AWS_DEFAULT_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}'`
[[ -d ~/.aws ]] || mkdir ~/.aws
echo "[default]
region=$AWS_DEFAULT_REGION
" > ~/.aws/config

# get dockercloud API key & set up dockercloud
apikey=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=dockercloud:api_key" | jq .Tags[0].Value)
apikey=$(echo "$apikey" | sed 's/^\"\(.*\)\"$/\1/g')

export DOCKERCLOUD_USER=gordonburgett
export DOCKERCLOUD_APIKEY=$apikey
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
echo '0 * * * * ubuntu /home/ubuntu/backup.sh s3://gordonburgett.net/backup >> /home/ubuntu/backup.log' | sudo tee /etc/cron.d/backup > /dev/null


# download mosh and other utils
sudo apt-get -y install mosh
