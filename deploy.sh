#! /bin/bash

hugo --baseUrl="http://www.gordonburgett.net"
rsync -az -e ssh --progress public/ ec2-user@www.gordonburgett.net:~/blog
rsync -e ssh package.json ec2-user@www.gordonburgett.net:~/