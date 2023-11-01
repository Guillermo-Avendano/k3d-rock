#!/bin/bash
chmod u+x *.sh

docker build --network host -t guillermoavendano/inputframework:4.8 .

read -s -p "Password: " DOCKER_PASSWORD
echo ""

docker login -u avendano.guillermo@gmail.com -p $DOCKER_PASSWORD

docker push guillermoavendano/inputframework:4.8