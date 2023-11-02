#!/bin/bash
chmod +x *.sh

docker build --network host -t guillermoavendano/outbound:6.1.1 .

read -s -p "Password: " DOCKER_PASSWORD
echo ""

docker login -u avendano.guillermo@gmail.com -p $DOCKER_PASSWORD

docker push guillermoavendano/outbound:6.1.1