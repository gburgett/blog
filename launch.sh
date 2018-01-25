#!/bin/bash
set -e -x

apt-get install -y unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

/usr/local/bin/aws s3 cp --recursive s3://gordonburgett.net/home/ /home/ubuntu/
chown -R ubuntu:ubuntu /home/ubuntu/

chmod +x /home/ubuntu/init.sh
echo 'Defaults:ubuntu !requiretty' > /etc/sudoers.d/ubuntu # temporarily allow sudo in script
su -c /home/ubuntu/init.sh ubuntu
rm /etc/sudoers.d/ubuntu