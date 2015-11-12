#!/bin/bash
set -e -x

yum install -y unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

/usr/local/bin/aws s3 cp --recursive s3://gordonburgett.net/home/ /home/ec2-user/
chown -R ec2-user:ec2-user /home/ec2-user/

chmod +x /home/ec2-user/init.sh
echo 'Defaults:ec2-user !requiretty' > /etc/sudoers.d/ec2-user # temporarily allow sudo in script
su -c /home/ec2-user/init.sh ec2-user
rm /etc/sudoers.d/ec2-user