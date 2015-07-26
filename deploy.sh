#! /bin/bash

user=ec2-user
server=ec2-54-149-172-147.us-west-2.compute.amazonaws.com

hugo --baseUrl="http://www.gordonburgett.net"
rsync -az -e ssh --progress public/ $user@$server:~/blog
rsync -e ssh package.json $user@$server:~/
rsync -e ssh haproxy.conf $user@$server:~/

ssh -t $user@$server 'bash -c "sudo haproxy -f haproxy.conf -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)"'