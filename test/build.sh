#!/bin/bash
docker build --network host -t registry.rocketsoftware.com/mobius-server:12.2.0-CECA .
k get deploym
docker tag registry.rocketsoftware.com/mobius-server:12.2.0-CECA guillermoavendano/mobius-server:12.2.0-CECA

docker login -u avendano.guillermo@gmail.com -p Guillei30

docker push guillermoavendano/mobius-server:12.2.0-CECA