#!/bin/bash

source "$kube_dir/env.sh"
source "$kube_dir/cluster/local_registry.sh"
source "$kube_dir/cluster/common.sh"

cluster_volumes () {

    if [ ! -d $KUBE_PV_ROOT ]; then
        mkdir -p $KUBE_PV_ROOT;
        chmod -R 777 $KUBE_PV_ROOT;
    fi 

    declare -A pv_folder

    export PV_PATH_aas_log_vol_claim=$KUBE_PV_ROOT/aas-log
    pv_folder['PV_PATH_aas_log_vol_claim']=$PV_PATH_aas_log_vol_claim

    export PV_PATH_aas_shared_claim=$KUBE_PV_ROOT/aas-shared
    pv_folder['PV_PATH_aas_shared_claim']=$PV_PATH_aas_shared_claim

    export PV_PATH_ifw_volume_claim=$KUBE_PV_ROOT/ifw-volume
    pv_folder['PV_PATH_ifw_volume_claim']=$PV_PATH_ifw_volume_claim

    export PV_PATH_ifw_inbox_claim=$KUBE_PV_ROOT/ifw-inbox
    pv_folder['PV_PATH_ifw_inbox_claim']=$PV_PATH_ifw_inbox_claim
    
    export PV_PATH_mobius_storage_claim=$KUBE_PV_ROOT/mobius-storage
    pv_folder['PV_PATH_mobius_storage_claim']=$PV_PATH_mobius_storage_claim

    export PV_PATH_mobius_diagnose_claim=$KUBE_PV_ROOT/mobius-diagnose
    pv_folder['PV_PATH_mobius_diagnose_claim']=$PV_PATH_mobius_diagnose_claim

    export PV_PATH_mobiusview_presentation_claim=$KUBE_PV_ROOT/mobiusview-presentation
    pv_folder['PV_PATH_mobiusview_presentation_claim']=$PV_PATH_mobiusview_presentation_claim

    export PV_PATH_mobiusview_diagnose_claim=$KUBE_PV_ROOT/mobiusview-diagnose
    pv_folder['PV_PATH_mobiusview_diagnoseview_claim']=$PV_PATH_mobiusview_diagnose_claim

    VOLUME_MAPPING=""
    for local_pv in ${!pv_folder[@]}; do
    if [ ! -d ${pv_folder[${local_pv}]} ]; then

        mkdir -p ${pv_folder[${local_pv}]};
        chmod -R 777 ${pv_folder[${local_pv}]};
    fi 
    VOL_MAP=`eval echo ${pv_folder[${local_pv}]}`
    VOLUME_MAPPING+="-v $VOL_MAP:$VOL_MAP "
    echo Creating: $local_pv ${pv_folder[${local_pv}]}
    done

    export KUBE_ARGS=$VOLUME_MAPPING

    echo KUBE_ARGS=$KUBE_ARGS

}
				  
create_cluster(){
    info_message "Creating registry $KUBE_LOCALREGISTRY_NAME"

    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    
    registry_file=$kube_dir/cluster/registry.yaml
    cp $kube_dir/cluster/template/registry-template.yaml $registry_file

    replace_tag_in_file $registry_file @KUBE_LOCALREGISTRY_HOST@ $KUBE_LOCALREGISTRY_HOST ;
    replace_tag_in_file $registry_file @KUBE_LOCALREGISTRY_PORT@ $KUBE_LOCALREGISTRY_PORT ;
    replace_tag_in_file $registry_file @KUBE_LOCALREGISTRY_NAME@ $KUBE_LOCALREGISTRY_NAME ;

    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi   
    k3d registry create $KUBE_LOCALREGISTRY_NAME --port 0.0.0.0:${KUBE_LOCALREGISTRY_PORT}

    info_message "Creating Volumes... in $HOME/$KUBE_CLUSTER_NAME"
    
    # local function - returns $KUBE_ARGS
    cluster_volumes $KUBE_CLUSTER_NAME

    info_message "Creating $KUBE_CLUSTER_NAME cluster..."
  
    KUBE_CLUSTER_REGISTRY="--registry-use k3d-$KUBE_LOCALREGISTRY_NAME:$KUBE_LOCALREGISTRY_PORT --registry-config $registry_file"

    k3d cluster create $KUBE_CLUSTER_NAME --api-port localhost:6444 -p "30776:30776@loadbalancer" -p "30779:30779@loadbalancer" -p "80:80@loadbalancer" -p "$NGINX_EXTERNAL_TLS_PORT:443@loadbalancer" --agents 2 --k3s-arg "--disable=traefik@server:0" $KUBE_CLUSTER_REGISTRY $KUBE_ARGS

    kubectl config use-context k3d-$KUBE_CLUSTER_NAME
    

    # Install ingress
    kubectl create namespace ingress-nginx
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml -n ingress-nginx
    info_progress_header "Verifying $KUBE_CLUSTER_NAME cluster..."

    POD_NAMES=("ingress-nginx-controller")
    # Define la cantidad de veces que se verificarán los pods
    NUM_CHECKS=10
    # Define la cantidad de tiempo que se esperará entre cada verificación (en segundos)
    WAIT_TIME=10
    # Loop sobre los nombres de los pods
    for POD_NAME in "${POD_NAMES[@]}"
    do
    # Inicializa una variable para contar el número de veces que se ha verificado el pod
    CHECKS=0  
        # Loop hasta que el pod esté en estado "Running"
        while [[ $(kubectl -n ingress-nginx get pods | grep $POD_NAME | awk '{print $3}') != "Running" ]]
        do
            # Incrementa el contador de verificación
            ((CHECKS++))         
            # Verifica si se ha alcanzado el número máximo de verificaciones
            if [[ $CHECKS -eq $NUM_CHECKS ]]; then
                error_message "ERROR: Cannot verify pod $POD_NAME after $NUM_CHECKS attempts"
                exit 1
            fi           
            # Espera antes de la siguiente verificación
            info_progress "..."
            sleep $WAIT_TIME
        done
    done

    highlight_message "$KUBE_CLUSTER_NAME cluster started !"						  
}

remove_cluster() {
    info_message "Removing $KUBE_CLUSTER_NAME cluster..."
    k3d cluster delete $KUBE_CLUSTER_NAME
    
    registry_name=k3d-$KUBE_LOCALREGISTRY_NAME
    if k3d registry list | grep $registry_name >/dev/null; then
        echo "Deleting existing registry $registry_name"
        k3d registry delete $registry_name
    fi  

    if [ -d $KUBE_PV_ROOT ]; then
       rm -rf $KUBE_PV_ROOT
    fi 

}

start_cluster() {
    info_message "Starting $KUBE_CLUSTER_NAME cluster..."
    k3d cluster start $KUBE_CLUSTER_NAME 
    kubectl config use-context k3d-$KUBE_CLUSTER_NAME    

    if k3d node list | grep "server-0" | grep exited  >/dev/null; then
       k3d node start k3d-$KUBE_CLUSTER_NAME-server-0
    fi 

    if k3d node list | grep agent-0 | grep exited  >/dev/null; then
       k3d node start k3d-$KUBE_CLUSTER_NAME-agent-0
    fi

    if k3d node list | grep agent-1 | grep exited  >/dev/null; then
       k3d node start k3d-$KUBE_CLUSTER_NAME-agent-0
    fi
    
    if k3d node list | grep "-serverlb" | grep exited  >/dev/null; then
       k3d node start k3d-$KUBE_CLUSTER_NAME-serverlb
    fi  
}

stop_cluster() {
    info_message "Stopping $KUBE_CLUSTER_NAME cluster"
    k3d cluster stop $KUBE_CLUSTER_NAME
}

list_cluster() {
    info_message "Cluster: $KUBE_CLUSTER_NAME"
    info_message "Cluster's list"
    k3d cluster list
}

isactive_cluster() {

    local cluster_status=$(k3d cluster list | grep "$KUBE_CLUSTER_NAME" | awk '{print $2}')
    
    if [[ "$cluster_status" == "1/1" ]]; then
        # Active
        return 0
    elif [[ -n "$cluster_status" ]]; then
        # Not active
        return 1
    else
        # Not exists
        return 1
    fi
}

exist_cluster() {

    local cluster_status=$(k3d cluster list | grep "$KUBE_CLUSTER_NAME" | awk '{print $2}')
    
    if [[ "$cluster_status" == "1/1" ]]; then
        # Active
        return 0
    elif [[ -n "$cluster_status" ]]; then
        # Not active
        return 0
    else
        # Not exists
        return 1
    fi
}


