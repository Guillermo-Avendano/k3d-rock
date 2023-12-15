#!/bin/bash
docker build --network host -t cups-server .
docker image prune 
