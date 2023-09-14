#!/bin/bash

set -Eeuo pipefail

java -jar -Dspring.profiles.active=demo ../JobExecutorCLI/aas-cli-11.1.2.jar -jobName ABSCMD  -user admin -password admin AC002_Balance ./data/AC002_POLICY.PLC ./data/$1
