#!/bin/bash
chmod +x *.sh

docker build --network host -t rocketsoftware2024/inputframework:4.8 .

read -s -p "Password: " DOCKER_PASSWORD
echo ""

docker login -u avendano.guillermo@gmail.com -p $DOCKER_PASSWORD

docker push rocketsoftware2024/inputframework:4.8