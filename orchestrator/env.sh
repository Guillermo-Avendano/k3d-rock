#!/bin/bash

source ../env.sh   # main env.sh

xargsflag="-d"
if [ $(uname -s) == "Darwin" ]; then
 xargsflag="-I"
fi
export $(grep -v '^#' .env | xargs ${xargsflag} '\n')

################################################################################
# ORCHESTRATOR CONFIGUTATION
################################################################################
export NAMESPACE="${NAMESPACE:=orchestrator}"
PRODUCT_FOLDER="orchestrator"

################################################################################
# IMAGES
################################################################################
IMAGE_SCHEDULER_NAME=aeo/scheduler
IMAGE_SCHEDULER_VERSION=${IMAGE_SCHEDULER_VERSION:-4.3.2.108}
IMAGE_CLIENTMGR_NAME=aeo/clientmgr
IMAGE_CLIENTMGR_VERSION=${IMAGE_CLIENTMGR_VERSION:-4.3.2.108}
IMAGE_AGENT_NAME=aeo/agent
IMAGE_AGENT_VERSION=${IMAGE_AGENT_VERSION:-4.3.2.108}

KUBE_IMAGE_PULL="YES"                             

export KUBE_IMAGES=("$IMAGE_SCHEDULER_NAME:$IMAGE_SCHEDULER_VERSION" "$IMAGE_CLIENTMGR_NAME:$IMAGE_CLIENTMGR_VERSION" "$IMAGE_AGENT_NAME:$IMAGE_AGENT_VERSION") # cluster/local_registry.sh

export KUBE_NS_LIST=( "$NAMESPACE" )

SCHEDULER_REPLICAS=2
CLIENTMGR_REPLICAS=1

################################################################################
# DATABASES
################################################################################
EXTERNAL_DATABASE=false
DATABASE_PROVIDER=postgresql
POSTGRESQL_VERSION=14.5.0
POSTGRESQL_USERNAME=aeo
POSTGRESQL_PASSWORD=aeo
POSTGRESQL_PASSENCR=3X6ApGn/D3cgkTxc730BGhvV6C6A6YPfGare9QjWgdT5rkI9wCWWFRvfYk1f5PXqN
POSTGRESQL_DBNAME=aeo
POSTGRESQL_HOST=postgresql
POSTGRESQL_PORT=5432
export POSTGRES_VALUES_TEMPLATE=postgres-aeo.yaml

#########################################
export AEO_URL=${AEO_URL:-orchestrator.local.net}


