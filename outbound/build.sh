#!/bin/bash
chmod +x *.sh

docker build --network host -t rocketsoftware2024/outbound:6.1.1 .

read -s -p "Password: " DOCKER_PASSWORD
echo ""

docker login -u rocketsoftware2024 -p $DOCKER_PASSWORD

docker push rocketsoftware2024/outbound:6.1.1