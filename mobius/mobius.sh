#!/bin/bash

set -Eeuo pipefail

source "../env.sh"
source "env.sh"
source ../cluster/common.sh
source ../cluster/namespace.sh
source ../cluster/local_registry.sh
source database/database.sh
source elasticsearch/elasticsearch.sh
source kafka/kafka.sh
source keycloak/keycloak.sh
source mobiusserver/mobiusserver.sh
source mobiusview/mobiusview.sh
source eventanalytics/eventanalytics.sh

echo "----------------"
echo "Namespaces: $NAMESPACE $NAMESPACE_SHARED"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - imgls     : list images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgpull   : pull images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgls-loc : list images from $KUBE_LOCALREGISTRY_NAME:$KUBE_LOCALREGISTRY_PORT"
  echo " - shinstall : Install shared resources (db, elastic, kafka)"
  echo " - shremove  : Remove shared resources (db, elastic, kafka)"
  echo " - install   : Install $PRODUCT (pre-reqs: 1.'imgpull', 2.'shinstall')"
  echo " - remove    : Remove $PRODUCT"
  echo " - sleep     : Sleep $PRODUCT (replicas=0)"
  echo " - wake      : Wake up $PRODUCT (replicas=normal)"
  echo " - debug     : Generate detail of kubernetes objects in namespaces"
  
else
  for option in "$@"; do

    if [[ $option == "imgpull" ]]; then
         # ../cluster/local_registry.sh
         push_images_to_local_registry; 

    elif [[ $option == "imgls-loc" ]]; then
         # ../cluster/local_registry.sh
         list_images_local;

    elif [[ $option == "imgls" ]]; then
         # ../cluster/local_registry.sh
         list_images;

    elif [[ $option == "shinstall" ]]; then
      export NAMESPACE=$NAMESPACE_SHARED;  

      #install database
      highlight_message "Deploying database services"

      install_database;

      info_progress_header "Waiting for database services to be ready ...";
      wait_for_database_ready;
      info_message "The database services are ready now.";

      #install keycloak
      if [ "$KEYCLOAK_ENABLED" == "true" ]; then
         highlight_message "Deploying Keycloak"
         install_keycloak;
         info_progress_header "Waiting for keycloak to be ready ...";
         wait_for_keycloak_ready;
      fi
      
      #install elasticsearch
      if [ "$ELASTICSEARCH_ENABLED" == "true" ]; then
        ELASTICSEARCH_VERSION="${ELASTICSEARCH_VERSION:-7.17.3}";
        ELASTICSEARCH_CONF_FILE=elasticsearch.yaml;
        ELASTICSEARCH_VOLUME=`eval echo ~/${NAMESPACE}_data/elasticsearch`
        ELASTICSEARCH_STORAGE_FILE=elasticsearch-storage.yaml;

        install_elasticsearch;
        wait_for_elasticsearch_ready; 
      fi

      #install kafka
      if [ "$KAFKA_ENABLED" == "true" ]; then
        KAFKA_VOLUME=`eval echo ~/${NAMESPACE}_data/kafka`
        KAFKA_CONF_FILE=kafka-statefulset.yaml;
        KAFKA_VERSION="${KAFKA_VERSION:-3.3.1-debian-11-r3}";
        KAFKA_STORAGE_FILE=kafka-storage.yaml;

        install_kafka;
        wait_for_kafka_ready;
      fi

      highlight_message "kubectl -n $NAMESPACE get pods"
      kubectl -n $NAMESPACE get pods

      highlight_message "kubectl -n $NAMESPACE get ingress"
      kubectl -n $NAMESPACE get ingress

    elif [[ $option == "shremove" ]]; then

      export NAMESPACE=$NAMESPACE_SHARED;

      #install database
      highlight_message "Uninstalling database services"

      uninstall_database;

      #uninstall Keycloak
      if [ "$KEYCLOAK_ENABLED" == "true" ]; then
         highlight_message "Uninstalling keycloak"
         uninstall_keycloak;
      fi

      #uninstall elasticsearch
      if [ "$ELASTICSEARCH_ENABLED" == "true" ]; then
        ELASTICSEARCH_VERSION="${ELASTICSEARCH_VERSION:-7.17.3}";
        ELASTICSEARCH_CONF_FILE=elasticsearch.yaml;
        ELASTICSEARCH_VOLUME=`eval echo ~/${NAMESPACE}_data/elasticsearch`
        ELASTICSEARCH_STORAGE_FILE=elasticsearch-storage.yaml;
        highlight_message "Uninstalling elasticsearch"
        uninstall_elasticsearch;
      fi

      #uninstall kafka
      if [ "$KAFKA_ENABLED" == "true" ]; then
        KAFKA_VOLUME=`eval echo ~/${NAMESPACE}_data/kafka`
        KAFKA_CONF_FILE=kafka-statefulset.yaml;
        KAFKA_VERSION="${KAFKA_VERSION:-3.3.1-debian-11-r3}";
        KAFKA_STORAGE_FILE=kafka-storage.yaml;

        highlight_message "Uninstalling kafka"
        uninstall_kafka;
      fi

      kubectl delete ns $NAMESPACE
		 
    elif [[ $option == "install" ]]; then

      install_eventanalytics
      wait_for_eventanalytics_ready

      install_mobius
      wait_for_mobius_ready

      install_mobiusview
      wait_for_mobiusview_ready
    
      highlight_message "kubectl -n $NAMESPACE get pods"
      kubectl -n $NAMESPACE get pods

      highlight_message "kubectl -n $NAMESPACE get ingress"
      kubectl -n $NAMESPACE get ingress
      

    elif [[ $option == "remove" ]]; then

      highlight_message "Uninstalling eventanalytics"
      remove_eventanalytics
      highlight_message "Uninstalling mobius"
      remove_mobius
      highlight_message "Uninstalling mobiusview"
      remove_mobiusview

      if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
        kubectl delete namespace $NAMESPACE
      fi
      
    elif [[ $option == "sleep" ]]; then
         
      highlight_message "Mobius 12 set replicas to 0"
      kubectl scale deployment eventanalytics --replicas=0 -n $NAMESPACE
      kubectl scale deployment mobiusview --replicas=0 -n $NAMESPACE
      kubectl scale deployment mobius  --replicas=0 -n $NAMESPACE

      kubectl scale statefulset postgresql --replicas=0 -n $NAMESPACE_SHARED
      kubectl scale statefulset kafka --replicas=0 -n $NAMESPACE_SHARED
      kubectl scale statefulset elasticsearch-master  --replicas=0 -n $NAMESPACE_SHARED

    elif [[ $option == "wake" ]]; then
         
      highlight_message "Mobius 12 set replicas to normal"
      kubectl scale statefulset postgresql --replicas=1 -n $NAMESPACE_SHARED
      kubectl scale statefulset kafka --replicas=1 -n $NAMESPACE_SHARED
      kubectl scale statefulset elasticsearch-master  --replicas=1 -n $NAMESPACE_SHARED

      kubectl scale deployment eventanalytics --replicas=1 -n $NAMESPACE
      kubectl scale deployment mobius  --replicas=1 -n $NAMESPACE
      kubectl scale deployment mobiusview --replicas=1 -n $NAMESPACE

    elif [[ $option == "debug" ]]; then
      debug_namespace;
    else    
      echo "($option) is not valid."
    fi
  done
fi
