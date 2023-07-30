#!/usr/bin/env bash

REPOSITORY="mynginx"
TAG="test"

docker images | grep $REPOSITORY | grep $TAG | awk '{print $3}' | xargs docker rmi -f

docker buildx build --tag $REPOSITORY:$TAG --output type=docker,dest=./output.tar .
docker import output.tar $REPOSITORY:$TAG
docker images | grep $REPOSITORY

docker run -itd -p 81:80 $REPOSITORY:$TAG /bin/bash
