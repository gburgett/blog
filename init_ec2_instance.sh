#!/bin/bash

set -e

identity=""
while getopts i: opt; do
  case $opt in 
  	i)
		identity="-i $OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
  esac
  shift $((OPTIND-1))
done

server=$1
[[ -z "$server" ]] && echo "expected server address" && exit -1

rsync -avz -e "ssh $identity" hosting/ ec2-user@$server:~/hosting

pubkey=`cat ~/.ssh/id_rsa.pub`


init="chmod -R 0700 ~/hosting
echo \"$pubkey\" >> ~/.ssh/authorized_keys
sudo yum -y install haproxy docker
sudo groupadd docker
sudo gpasswd -a ec2-user docker
sudo service docker start
sudo /usr/sbin/haproxy -f /home/ec2-user/hosting/haproxy.conf -D"
ssh -t $identity ec2-user@$server "$init"

# log out to join the docker group
#uuid=`uuidgen`
uuid="30b96b9c-bff4-4f6b-a0fc-df88d045c8a2"
run="docker run --restart=always -d -p 8080:8080 -p 8081:8081 gordonburgett/blog || echo \"already running\"

curl https://raw.githubusercontent.com/schickling/docker-hook/master/docker-hook > /home/ec2-user/hosting/docker-hook; chmod +x /home/ec2-user/hosting/docker-hook
nohup /home/ec2-user/hosting/docker-hook -t $uuid -c /bin/bash /home/ec2-user/hosting/update_container.sh &"
ssh -t ec2-user@$server "$run"

echo "Add this to dockerhub hook:"
echo "http://www.gordonburgett.net:8555/$uuid"

#docker-hook -t /30b96b9c-bff4-4f6b-a0 fc-df88d045c8a2 -c "sh /home/ec2-user/hosting/update_container.sh gordonburgett/blog > /home/ec2-user/hosting/hook_out.txt 2>&1 " & 