#!/bin/bash
set -Eeuo pipefail

source ../env.sh
source ./env.sh
source ../cluster/common.sh

install_mobiusview() {
	
	MOBIUSVIEW_STORAGE_FILE=mobiusview_storage.yaml;
    cp $kube_dir/mobius//mobiusview/storage/local/templates/$MOBIUSVIEW_STORAGE_FILE $kube_dir/mobius/mobiusview/$MOBIUSVIEW_STORAGE_FILE;
	
	replace_tag_in_file $kube_dir/mobius/mobiusview/$MOBIUSVIEW_STORAGE_FILE "<PV_PATH_mobiusview_presentation_claim>" $PV_PATH_mobiusview_presentation_claim;
	replace_tag_in_file $kube_dir/mobius/mobiusview/$MOBIUSVIEW_STORAGE_FILE "<PV_PATH_mobiusview_diagnose_claim>" $PV_PATH_mobiusview_diagnose_claim;
	
	MOBIUSVIEW_VALUES_FILE=mobiusview.yaml;
    cp $kube_dir/mobius/mobiusview/templates/$MOBIUSVIEW_VALUES_FILE $kube_dir/mobius/mobiusview/$MOBIUSVIEW_VALUES_FILE;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<KUBE_LOCALREGISTRY_HOST>" $KUBE_LOCALREGISTRY_HOST;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<KUBE_LOCALREGISTRY_PORT>" $KUBE_LOCALREGISTRY_PORT;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<IMAGE_NAME_MOBIUSVIEW>" $IMAGE_NAME_MOBIUSVIEW;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<IMAGE_VERSION_MOBIUSVIEW>" $IMAGE_VERSION_MOBIUSVIEW;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_USERNAME>" $POSTGRESQL_USERNAME;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_PASSWORD>" $POSTGRESQL_PASSWORD;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_HOST>" $POSTGRESQL_HOST;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_PORT>" $POSTGRESQL_PORT;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_DBNAME_MOBIUSVIEW>" $POSTGRESQL_DBNAME_MOBIUSVIEW;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<NAMESPACE>" $NAMESPACE;
	replace_tag_in_file $kube_dir/mobius//mobiusview/$MOBIUSVIEW_VALUES_FILE "<KAFKA_BOOTSTRAP_URL>" $KAFKA_BOOTSTRAP_URL;

	MOBIUSVIEW_INGRESS_FILE=mobiusview-ingress.yaml;
    cp $kube_dir/mobius/mobiusview/templates/ingress/$MOBIUSVIEW_INGRESS_FILE $kube_dir/mobius/mobiusview/$MOBIUSVIEW_INGRESS_FILE;

	replace_tag_in_file $kube_dir/mobius/mobiusview/$MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL>" $MOBIUS_VIEW_URL;
	replace_tag_in_file $kube_dir/mobius/mobiusview/$MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL2>" $MOBIUS_VIEW_URL2;


    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
    fi

	info_message "Applying secrets";

	kubectl --namespace $NAMESPACE create secret generic mobius-license --from-literal=license=$MOBIUS_LICENSE
	
	  
    # tls
	#if [ ! -f "$kube_dir/mobius/mobiusview/$MOBIUS_VIEW_URL.key" ]; then
	#   openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "$kube_dir/mobius/mobiusview/$MOBIUS_VIEW_URL.key" -out "$kube_dir/mobius/mobiusview/$MOBIUS_VIEW_URL.crt" -subj "/CN=$MOBIUS_VIEW_URL" -addext "subjectAltName=DNS:$MOBIUS_VIEW_URL" -addext 'extendedKeyUsage=serverAuth,clientAuth'
	#   openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "$kube_dir/mobius/mobiusview/$MOBIUS_VIEW_URL2.key" -out "$kube_dir/mobius/mobiusview/$MOBIUS_VIEW_URL2.crt" -subj "/CN=$MOBIUS_VIEW_URL2" -addext "subjectAltName=DNS:$MOBIUS_VIEW_URL2" -addext 'extendedKeyUsage=serverAuth,clientAuth'

	# kubectl create secret generic mi-secreto-tls --from-file=mi-certificado.crt=path/al/archivo/mi-certificado.crt --from-file=mi-clave.key=path/al/archivo/mi-clave.key


    info_message "Creating mobiusview storage";    
    kubectl apply -f $kube_dir/mobius//mobiusview/mobiusview_storage.yaml --namespace $NAMESPACE;
	
	info_message "Deploy mobiusview"; 
	helm upgrade mobiusview -n $NAMESPACE $kube_dir/mobius/mobiusview/helm/mobiusview.tgz --create-namespace -f $kube_dir/mobius/mobiusview/mobiusview.yaml --install	
	
	info_message "Creating mobiusview ingress";    
    kubectl apply -f $kube_dir/mobius/mobiusview/$MOBIUSVIEW_INGRESS_FILE --namespace $NAMESPACE;
}

wait_for_mobiusview_ready() {
    info_message "Waiting for mobiusview to be ready";
    COUNTER=0
	output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    until [[ "$output" == *mobiusview* ]]
    do
        info_progress "...";
		let COUNTER=COUNTER+5
		if [[ "$COUNTER" -gt 300 ]]; then
		  echo "FATAL: Failed to install mobiusview. Please check logs and configuration"
          exit 1    
		fi
        sleep 5;
		output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    done

	pod_name="mobiusview"

	pod=$(kubectl -n $NAMESPACE get pods --output=name | grep "$pod_name")

	if kubectl -n $NAMESPACE get pods --output=name | grep "$pod_name"; then
		kubectl -n $NAMESPACE delete "$pod"
	fi

    info_message "Waiting for mobiusview to be ready";
    COUNTER=0
	output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    until [[ "$output" == *mobiusview* ]]
    do
        info_progress "...";
		let COUNTER=COUNTER+5
		if [[ "$COUNTER" -gt 300 ]]; then
		  echo "FATAL: Failed to install mobiusview. Please check logs and configuration"
          exit 1    
		fi
        sleep 5;
		output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    done
}

remove_mobiusview() {

    info_message "Removing mobiusview"; 
	helm uninstall mobiusview -n $NAMESPACE

	kubectl delete pvc mobius-storage-claim --namespace $NAMESPACE 	
	kubectl delete pvc mobiusview-diagnose-claim --namespace $NAMESPACE 
	kubectl delete pvc mobiusview-presentation-claim --namespace $NAMESPACE 
	
	kubectl delete pv mobius-storage --namespace $NAMESPACE 
	kubectl delete pv mobiusview-diagnose --namespace $NAMESPACE 
	kubectl delete pv mobiusview-presentation --namespace $NAMESPACE 
	kubectl delete secret mobius-license --namespace $NAMESPACE 
	
}

test(){
	MOBIUSVIEW_LICENSE_FILE=mobius-license.yaml;
}