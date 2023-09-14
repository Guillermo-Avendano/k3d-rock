#!/bin/bash

source "$kube_dir/cluster/common.sh"


install_database() {
    
    info_message "Installing $DATABASE_PROVIDER database ..."

    if [ "$DATABASE_PROVIDER" == "postgresql" ]; then
        info_message "Creating database namespace and storage";
            
        if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
            kubectl create namespace "$NAMESPACE";
        fi 
        
        POSTGRES_STORAGE=postgres-storage.yaml
        POSTGRES_VALUES=postgres-aaservices.yaml

        cp $kube_dir/aaservices/database/templates/$POSTGRES_STORAGE $kube_dir/aaservices/database/$POSTGRES_STORAGE;
        cp $kube_dir/aaservices/database/templates/$POSTGRES_VALUES $kube_dir/aaservices/database/$POSTGRES_VALUES;
        
        POSTGRES_CONF_FILE=$kube_dir/aaservices/database/$POSTGRES_VALUES;


        POSTGRESQL_VERSION="${POSTGRESQL_VERSION:-14.5.0}";

        info_message "Configuring Postgresql $POSTGRESQL_VERSION resources";

        replace_tag_in_file $POSTGRES_CONF_FILE "<image_tag>" $POSTGRESQL_VERSION;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_user>" $POSTGRESQL_USERNAME;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_password>" $POSTGRESQL_PASSWORD;
        replace_tag_in_file $POSTGRES_CONF_FILE "<database_name>" $POSTGRESQL_DBNAME;
        replace_tag_in_file $POSTGRES_CONF_FILE "<postgres_port>" $POSTGRESQL_PORT;

        kubectl apply -f $kube_dir/aaservices/database/$POSTGRES_STORAGE --namespace $NAMESPACE;
        
        info_message "Updating local Helm repository";

        helm repo add bitnami https://charts.bitnami.com/bitnami;
        helm repo update;

        info_message "Deploying postgresql Helm chart";

        helm upgrade -f $POSTGRES_CONF_FILE postgresql bitnami/postgresql --namespace $NAMESPACE --create-namespace --version 11.8.2 --install;

    else
        error_message "Unexpected DATABASE_PROVIDER value: $DATABASE_PROVIDER";
    fi
    
    
}

uninstall_database() {
    POSTGRES_STORAGE_FILE=postgres-storage.yaml
    helm uninstall postgresql --namespace $NAMESPACE;
    	
    kubectl delete -f $kube_dir/aaservices/database/$POSTGRES_STORAGE_FILE --namespace $NAMESPACE;
}

get_database_status() {
    kubectl get pods --namespace $NAMESPACE postgresql-0 -o jsonpath="{.status.phase}" 2>/dev/null
}

wait_for_database_ready() {
    until [ "$(get_database_status)" == "Running" ]
    do
        info_progress "...";
        sleep 3;
    done
    info_message "database started successfully";
}

get_database_service() {
    echo $POSTGRESQL_HOST
}

get_database_port() {
    echo $POSTGRESQL_PORT
}