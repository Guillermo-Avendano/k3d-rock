#!/bin/bash
docker build --network host -t guillermoavendano/printagent:12.3 -f dockerfile.printagent .
docker image prune 
