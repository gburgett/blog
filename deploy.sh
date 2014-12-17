#! /bin/bash

hugo --baseUrl="http://www.gordonburgett.net"
cd ./public
scp -i $1 -r ./ ec2-user@gordonburgett.net:/var/www/html