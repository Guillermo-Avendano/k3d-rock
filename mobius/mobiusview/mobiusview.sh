#!/bin/bash
set -Eeuo pipefail

source ../env.sh
source ./env.sh
source ../cluster/common.sh

install_mobiusview() {

    ################################ STORAGE #################################
	if [ "$KUBE_PV_ROOT_MAP_ALL" == "true" ]; then
	    MOBIUSVIEW_STORAGE_FILE_TEMPLATE=$kube_dir/mobius/mobiusview/templates/storage/mobiusview_storage.yaml;
	else
	    MOBIUSVIEW_STORAGE_FILE_TEMPLATE=$kube_dir/mobius/mobiusview/templates/storage/mobiusview_storage-local.yaml;
	fi	

	MOBIUSVIEW_STORAGE_FILE=$kube_dir/mobius/mobiusview/deploy/mobiusview_storage.yaml;
    cp $MOBIUSVIEW_STORAGE_FILE_TEMPLATE $MOBIUSVIEW_STORAGE_FILE;
	
	replace_tag_in_file $MOBIUSVIEW_STORAGE_FILE "<MOBIUSVIEW_PV_PRESENTATION>" $MOBIUSVIEW_PV_PRESENTATION;
	replace_tag_in_file $MOBIUSVIEW_STORAGE_FILE "<MOBIUSVIEW_PV_DIAGNOSE>" $MOBIUSVIEW_PV_DIAGNOSE;
	replace_tag_in_file $MOBIUSVIEW_STORAGE_FILE "<KUBE_STORAGE_CLASS>" $KUBE_STORAGE_CLASS
	replace_tag_in_file $MOBIUSVIEW_STORAGE_FILE "<KUBE_STORAGE_READ_WRITE>" $KUBE_STORAGE_READ_WRITE
	
	################################ VALUES #################################
	MOBIUSVIEW_VALUES_FILE_TEMPLATE=$kube_dir/mobius/mobiusview/templates/values/mobiusview.yaml;
	MOBIUSVIEW_VALUES_FILE=$kube_dir/mobius/mobiusview/deploy/mobiusview.yaml;

    cp /$MOBIUSVIEW_VALUES_FILE_TEMPLATE $MOBIUSVIEW_VALUES_FILE;

	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<KUBE_LOCALREGISTRY_HOST>" $KUBE_LOCALREGISTRY_HOST;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<KUBE_LOCALREGISTRY_PORT>" $KUBE_LOCALREGISTRY_PORT;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<IMAGE_NAME_MOBIUSVIEW>" $IMAGE_NAME_MOBIUSVIEW;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<IMAGE_VERSION_MOBIUSVIEW>" $IMAGE_VERSION_MOBIUSVIEW;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_USERNAME>" $POSTGRESQL_USERNAME;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_PASSWORD>" $POSTGRESQL_PASSWORD;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_HOST>" $POSTGRESQL_HOST;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_PORT>" $POSTGRESQL_PORT;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<POSTGRESQL_DBNAME_MOBIUSVIEW>" $POSTGRESQL_DBNAME_MOBIUSVIEW;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<NAMESPACE>" $NAMESPACE;
	replace_tag_in_file $MOBIUSVIEW_VALUES_FILE "<KAFKA_BOOTSTRAP_URL>" $KAFKA_BOOTSTRAP_URL;

    ################################ INGRESSES #################################
    MOBIUS_VIEW_URL_SECRET=`echo "$MOBIUS_VIEW_URL" | sed -r 's#\.#-#g'`
	MOBIUS_VIEW_URL2_SECRET=`echo "$MOBIUS_VIEW_URL2" | sed -r 's#\.#-#g'`

	gen_certificate $MOBIUS_VIEW_URL $MOBIUS_VIEW_URL_SECRET
	gen_certificate $MOBIUS_VIEW_URL2 $MOBIUS_VIEW_URL2_SECRET

	MOBIUSVIEW_INGRESS_FILE_TEMPLATE=$kube_dir/mobius/mobiusview/templates/ingress/mobiusview-ingress.yaml;
	MOBIUSVIEW_INGRESS_FILE=$kube_dir/mobius/mobiusview/deploy/mobiusview-ingress.yaml;;
    cp $MOBIUSVIEW_INGRESS_FILE_TEMPLATE $MOBIUSVIEW_INGRESS_FILE;

	replace_tag_in_file $MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL>" $MOBIUS_VIEW_URL;
	replace_tag_in_file $MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL2>" $MOBIUS_VIEW_URL2;
    replace_tag_in_file $MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL_SECRET>" $MOBIUS_VIEW_URL_SECRET-secret-tls;
	replace_tag_in_file $MOBIUSVIEW_INGRESS_FILE "<MOBIUS_VIEW_URL2_SECRET>" $MOBIUS_VIEW_URL2_SECRET-secret-tls;
	
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
	   if [ "$KUBE_ISTIO_ENABLED" == "true" ]; then
          kubectl label namespace $NAMESPACE istio-injection=enabled
       fi  
    fi

	info_message "Applying secrets";
	
	cert_directory="$kube_dir/cluster/cert"
	
	kubectl --namespace $NAMESPACE apply -f "$cert_directory/$MOBIUS_VIEW_URL-secrets.yaml"
    info_message "Certificate for $MOBIUS_VIEW_URL: $cert_directory/$MOBIUS_VIEW_URL.crt";

	kubectl --namespace $NAMESPACE apply -f "$cert_directory/$MOBIUS_VIEW_URL2-secrets.yaml"
	info_message "Certificate for $MOBIUS_VIEW_URL2: $cert_directory/$MOBIUS_VIEW_URL2.crt";

	kubectl --namespace $NAMESPACE create secret generic mobius-license --from-literal=license=$MOBIUS_LICENSE
	
    info_message "Creating mobiusview storage";    
    kubectl apply -f $MOBIUSVIEW_STORAGE_FILE --namespace $NAMESPACE;
	
	info_message "Deploy mobiusview"; 
	helm upgrade mobiusview -n $NAMESPACE $kube_dir/mobius/mobiusview/helm/mobiusview.tgz --create-namespace -f $MOBIUSVIEW_VALUES_FILE --install	
	
	info_message "Creating mobiusview ingress";    
    kubectl apply -f $MOBIUSVIEW_INGRESS_FILE --namespace $NAMESPACE;
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