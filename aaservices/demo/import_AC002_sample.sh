#!/bin/sh

# Copyright (c) 2003-2023 Rocket software, Inc. or its affiliates. All rights reserved.
#
# Audit & Analytics Services
#
# This script creates all applications and tasks present in the Exported_Samples file
#
java -jar -Dspring.profiles.active=docker ../JobExecutorCLI/aas-cli-11.1.2.jar -jobName XMLImport -user admin -password admin -file ./data/AC002_Balance_Full.xml  -loadtype BOTH -importfromolderthan9 true
