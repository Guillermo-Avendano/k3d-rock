#!/bin/bash
set -Eeuo pipefail

source "$kube_dir/env.sh"
source "$kube_dir/mobius/env.sh"
source "$kube_dir/cluster/common.sh"

install_kafka() {
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        kubectl create namespace "$NAMESPACE";
        if [ "$KUBE_ISTIO_ENABLED_SHARED" == "true" ]; then
            kubectl label namespace $NAMESPACE istio-injection=enabled
        fi  
    fi 
      
    info_message "Configuring kafka $KAFKA_VERSION resources";
				
    cp $kube_dir/mobius/kafka/storage/local/templates/$KAFKA_STORAGE_FILE $kube_dir/mobius/kafka/storage/local/$KAFKA_STORAGE_FILE;
	replace_tag_in_file $kube_dir/mobius/kafka/storage/local/$KAFKA_STORAGE_FILE "<KAFKA_VOLUME>" $KAFKA_VOLUME;
   
    cp $kube_dir/mobius/kafka/templates/$KAFKA_CONF_FILE $kube_dir/mobius/kafka/$KAFKA_CONF_FILE;
    replace_tag_in_file $kube_dir/mobius/kafka/$KAFKA_CONF_FILE "<KAFKA_VERSION>" $KAFKA_VERSION; 
	
	kubectl apply -f  $kube_dir/mobius/kafka/storage/local/$KAFKA_STORAGE_FILE --namespace $NAMESPACE
	
	kubectl apply -f  $kube_dir/mobius/kafka/$KAFKA_CONF_FILE --namespace $NAMESPACE 
	
	#info_message "Clean up resources";
    rm -f $kube_dir/mobius/kafka/$KAFKA_CONF_FILE
    rm -f $kube_dir/mobius/kafka/storage/local/$KAFKA_STORAGE_FILE	
}

get_kafka_status() {
    kubectl get pods --namespace $NAMESPACE kafka-0 -o jsonpath="{.status.phase}" 2>/dev/null
}

uninstall_kafka() {
    cp $kube_dir/mobius/kafka/templates/$KAFKA_CONF_FILE $kube_dir/mobius/kafka/$KAFKA_CONF_FILE;
    replace_tag_in_file $kube_dir/mobius/kafka/$KAFKA_CONF_FILE "<KAFKA_VERSION>" $KAFKA_VERSION; 
    info_message "Deleting $KAFKA_VERSION resources";
	kubectl delete -f  $kube_dir/mobius/kafka/$KAFKA_CONF_FILE --namespace $NAMESPACE  
	rm -f $kube_dir/mobius/kafka/$KAFKA_CONF_FILE
}

wait_for_kafka_ready() {
    info_message "Waiting for kafka to be ready";
    COUNTER=0
    until [ "$(get_kafka_status)" == "Running" ]
    do
        info_progress "...";
		let COUNTER=COUNTER+5
		if [[ "$COUNTER" -gt 600 ]]; then
		  echo "FATAL: Failed to install kafka. Please check logs and configuration"
          exit 1    
		fi
        sleep 3;
    done
    info_message "Kafka started successfully";
}



#NAMESPACE=$TF_VAR_NAMESPACE_SHARED
#KAFKA_VOLUME=`eval echo ~/${NAMESPACE}_data/kafka`
#KAFKA_CONF_FILE=kafka-statefulset.yaml;
#KAFKA_VERSION="${KAFKA_VERSION:-3.3.1-debian-11-r3}";
#KAFKA_STORAGE_FILE=kafka-storage.yaml;

#install_kafka;
#wait_for_kafka_ready;