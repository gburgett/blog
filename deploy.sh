#! /bin/bash

hugo --baseUrl="http://www.gordonburgett.net"
rsync -az -e ssh --progress public/ ec2-user@ec2-54-149-172-147.us-west-2.compute.amazonaws.com:~/blog
rsync -e ssh package.json ec2-user@ec2-54-149-172-147.us-west-2.compute.amazonaws.com:~/