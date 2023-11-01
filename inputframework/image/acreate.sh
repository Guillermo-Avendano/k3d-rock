#!/bin/bash
PATH=/opt/asg/java/bin:$PATH

java -D"log4j.configurationFile=$MOBIUS_REMOTE_CLI_PATH/BOOT-INF/classes/log4j2.yaml" -jar ${MOBIUS_REMOTE_CLI_PATH}/acreate-cli.jar acreate $@
