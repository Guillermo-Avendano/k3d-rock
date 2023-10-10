#!/bin/bash

################################################################################
# MOBIUS CONFIG
################################################################################
NAMESPACE=mobius
NAMESPACE_SHARED=shared

PRODUCT="Mobius 12.2.0"

export KUBE_NS_LIST=( "$NAMESPACE" "$NAMESPACE_SHARED" )

################################################################################
# MOBIUS 
################################################################################
MOBIUS_LICENSE=$MOBIUS_LICENSE
IMAGE_NAME_MOBIUS=mobius-server
IMAGE_VERSION_MOBIUS=${IMAGE_VERSION_MOBIUS:-12.2.0}
IMAGE_NAME_MOBIUSVIEW=mobius-view
IMAGE_VERSION_MOBIUSVIEW=${IMAGE_VERSION_MOBIUSVIEW:-12.2.1}
IMAGE_NAME_EVENTANALYTICS=eventanalytics
IMAGE_VERSION_EVENTANALYTICS=${IMAGE_VERSION_EVENTANALYTICS:-1.3.18}
MOBIUS_VIEW_URL=${MOBIUS_VIEW_URL:-mobius12.local.net}
MOBIUS_VIEW_URL2=${MOBIUS_VIEW_URL2:-mobius12.lapubuntu.net}

export KUBE_IMAGES=("mobius-server:$IMAGE_VERSION_MOBIUS" "mobius-view:$IMAGE_VERSION_MOBIUSVIEW" "eventanalytics:$IMAGE_VERSION_EVENTANALYTICS") # cluster/local_registry.sh


################################################################################
# DATABASES
################################################################################
EXTERNAL_DATABASE=false
POSTGRESQL_VERSION=14.5.0
POSTGRESQL_USERNAME=mobius
POSTGRESQL_PASSWORD=postgres
POSTGRESQL_DBNAME_MOBIUSVIEW=mobiusview
POSTGRESQL_DBNAME_MOBIUS=mobiusserver
POSTGRESQL_DBNAME_EVENTANALYTICS=eventanalytics
POSTGRESQL_DBNAME_KEYCLOAK=keycloak
POSTGRESQL_HOST=postgresql.$NAMESPACE_SHARED
POSTGRESQL_PORT=5432
POSTGRES_VALUES_TEMPLATE=postgres-mobius.yaml


################################################################################
# KEYCLOAK
################################################################################
export KEYCLOAK_ENABLED=${KEYCLOAK_ENABLED:-false}    # true for Authentication or AAS Integration
export KEYCLOAK_HELM_DEPLOY_NAME=keycloak
export KEYCLOAK_URL=${KEYCLOAK_URL:-keycloak.local.net} 

################################################################################
# ELASTICSEARCH
################################################################################
ELASTICSEARCH_ENABLED=true

ELASTICSEARCH_VERSION=7.17.13
ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-elastic.local.net} 
ELASTICSEARCH_HOST=elasticsearch-master.shared
ELASTICSEARCH_PORT=9200

MOBIUS_FTS_INDEX_NAME="mobius"

# mobius service/port for comunication mobius with mobiusviews
MOBIUS_HOST="mobius"
MOBIUS_HOST="8080"

################################################################################
# KAFKA
################################################################################
KAFKA_ENABLED=true
KAFKA_VERSION=3.3.1-debian-11-r3
KAFKA_BOOTSTRAP_URL=kafka.$NAMESPACE_SHARED:9092
