#!/bin/bash
docker build --network host -t rocketsoftware2024/printagent:12.3 -f dockerfile.printagent .
docker image prune 
