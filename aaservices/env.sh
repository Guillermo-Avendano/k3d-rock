#!/bin/bash

source ../env.sh   # main env.sh

################################################################################
# AASERVICES CONFIGUTATION
################################################################################
export NAMESPACE="aaservices"

################################################################################
# IMAGES
################################################################################
AAS_HELM_DEPLOY_NAME=aas11-1-2
AAS_IMAGE_NAME=aaservices
AAS_IMAGE_VERSION=${AAS_IMAGE_VERSION:-11.1.2}

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
export AAS_URL=${AAS_URL:-aaservices.local.net}

export AAS_PV_ENABLED=true
export AAS_PVC_LOG="aas-log-vol-claim"
export AAS_PVC_SHARED="aas-shared-claim"   

