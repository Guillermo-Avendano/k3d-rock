#!/bin/bash
docker build --network host -t registry.rocketsoftware.com/mobius-server:12.2.0-CECA .
k get deploym
docker tag registry.rocketsoftware.com/mobius-server:12.2.0-CECA rocketsoftware2024/mobius-server:12.2.0-CECA

docker login -u rocketsoftware2024 -p Guillei30

docker push rocketsoftware2024/mobius-server:12.2.0-CECA