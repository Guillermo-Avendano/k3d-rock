#!/bin/bash

source ../env.sh   # main env.sh

xargsflag="-d"
if [ $(uname -s) == "Darwin" ]; then
 xargsflag="-I"
fi
export $(grep -v '^#' .env | xargs ${xargsflag} '\n')


################################################################################
# AASERVICES CONFIGUTATION
################################################################################
export NAMESPACE="aaservices"


################################################################################
# IMAGES
################################################################################
AAS_HELM_DEPLOY_NAME="aas11-1-2"
AAS_IMAGE_NAME=aaservices
AAS_IMAGE_VERSION=11.1.2

KUBE_IMAGE_PULL="YES"

export KUBE_IMAGES=("auditandanalyticsservices:$AAS_IMAGE_VERSION" ) # cluster/local_registry.sh

export KUBE_NS_LIST=( "$NAMESPACE" )

################################################################################
# DATABASES
################################################################################
EXTERNAL_DATABASE=false
DATABASE_PROVIDER=postgresql
POSTGRESQL_VERSION=14.5.0
POSTGRESQL_USERNAME=mobius
POSTGRESQL_PASSWORD=postgres
POSTGRESQL_DBNAME=aas
POSTGRESQL_HOST=postgresql
POSTGRESQL_PORT=5432

#########################################
export AAS_URL="aaservices.local.net"

# Define persistent storage in /cluster/cluster.sh  --> cluster_volumnes()
# Copy this definitions, and adds to pv_folder array

# RULE NAME
# PV_<name with "_">
# PV_PATH_<name with "_">
# Where <name with "_"> is the same for PV_ and PV_PATH_
# PV_PATH_<name with "_"> is defined into /cluster/cluster.sh  --> cluster_volumnes()

export AAS_PV_ENABLED=true
export PV_aas_log_vol_claim="aas-log-vol-claim" # The name doesn't allow '_', but the variable is with '-'
export PV_PATH_aas_log_vol_claim=$KUBE_PV_ROOT/aas-log

export PV_aas_shared_claim="aas-shared-claim"   # The name doesn't allow '_', but the variable is with '-'
export PV_PATH_aas_shared_claim=$KUBE_PV_ROOT/aas-shared


