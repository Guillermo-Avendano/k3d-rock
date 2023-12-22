#!/bin/bash
docker build --network host -t rocketsoftware2024/mobius-server:12.2.0-CECA .

docker login -u rocketsoftware2024 -p Rocket2024

docker push rocketsoftware2024/mobius-server:12.2.0-CECA