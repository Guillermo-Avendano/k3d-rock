#!/bin/sh

# Copyright (c) 2003-2023 Rocket software, Inc. or its affiliates. All rights reserved.
#
# Audit & Analytics Services
#
# This script creates all applications and tasks present in the Exported_Samples file
#

source $CATALINA_HOME/bin/check_aas_started.sh

if [[ ! -f $MOBIUS_DIR/Docker/samples-imported && $? = 0 ]]; then
    echo -e "Importing Samples"

    java -jar -Dspring.profiles.active=docker $MOBIUS_DIR/Samples/Demo_All_Samples/Docker/aas-cli-11.1.2.jar -jobName XMLImport -user admin -password admin -file $MOBIUS_DIR/Samples/Demo_All_Samples/Exported_Samples.xml  -loadtype BOTH -importfromolderthan9 true

    echo -e "Samples are imported"
    touch $MOBIUS_DIR/Docker/samples-imported
else
    echo -e "Samples are already imported"
fi