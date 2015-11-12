#!/bin/bash

[[ -z "$1" ]] && echo "container name expected" && exit 1

IMAGE="$1"
echo "restarting $IMAGE"
docker ps | grep $IMAGE | awk '{print $1}' | xargs docker stop
docker pull $IMAGE
docker run --restart=always -d -p 8080:8080 -p 8081:8081 $IMAGE