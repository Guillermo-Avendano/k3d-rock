#!/bin/bash
PATH=/opt/asg/java/bin:$PATH
MOBIUS_REMOTE_CLI_PATH=/opt/MobiusRemoteCLI
java -cp "$MOBIUS_REMOTE_CLI_PATH/BOOT-INF/classes:$MOBIUS_REMOTE_CLI_PATH/BOOT-INF/lib/*" com.asg.mobiuscli.MobiusCliApplication $@
