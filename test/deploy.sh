#!/bin/bash
replace_tag_in_file() {
    local filename=$1
    local search=$2
    local replace=$3

    if [[ $search != "" ]]; then
        # Escape not allowed characters in sed tool
        search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^[]/\\&/g');
        replace=$(printf '%s\n' "$replace" | sed -e 's/[]\/$*.^[]/\\&/g');
        sed -i'' -e "s/$search/$replace/g" $filename
    fi
}

gen_certificate(){
   if [[ $# -eq 0 ]] ; then
      echo "No arguments supplied"
   else
      varhost=$1
      varhost_secret=$2
   fi

   cert_directory="./"
   
   cert_file="$cert_directory/$varhost-secrets.yaml"
    
   if [ ! -f $cert_file ]; then
      openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "$cert_directory/$varhost.key" -out "$cert_directory/$varhost.crt" -subj "/CN=$varhost" -addext "subjectAltName=DNS:$varhost" -addext 'extendedKeyUsage=serverAuth,clientAuth'
      mycrt="$(cat $cert_directory/$varhost.crt | base64)"
      mykey="$(cat $cert_directory/$varhost.key | base64)"
      mycrt=$(echo $mycrt | tr -d ' ')
      mykey=$(echo $mykey | tr -d ' ')

      SECRET_FILE=$cert_directory/$varhost-secrets.yaml
      
      echo -e "apiVersion: v1\nkind: Secret\ndata:\n  tls.crt: #CRT#\n  tls.key: #KEY#\nmetadata:\n  name: #NAME#\ntype: kubernetes.io/tls" > $SECRET_FILE

      replace_tag_in_file $SECRET_FILE "#CRT#" $mycrt;
      replace_tag_in_file $SECRET_FILE "#KEY#" $mykey;
      replace_tag_in_file $SECRET_FILE "#NAME#" $varhost_secret;
      
      kubectl create secret tls "$varhost_secret" --key "$cert_directory/$varhost.key" --cert "$cert_directory/$varhost.crt" --dry-run="client" -o="yaml" >> "$SECRET_FILE-1.yaml"
   fi  

}

gen_certificate1(){
   if [[ $# -eq 0 ]] ; then
      echo "No arguments supplied"
   else
      varhost=$1
      varhost_secret=$2
   fi

   cert_directory="./"
   
   cert_file="$cert_directory/$varhost-secrets.yaml"
    
   if [ ! -f $cert_file ]; then
      openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "$cert_directory/$varhost.key" -out "$cert_directory/$varhost.crt" -subj "/CN=$varhost" -addext "subjectAltName=DNS:$varhost" -addext 'extendedKeyUsage=serverAuth,clientAuth'

      SECRET_FILE=$cert_directory/$varhost-secrets.yaml
           
      kubectl create secret tls "$varhost_secret" --key "$cert_directory/$varhost.key" --cert "$cert_directory/$varhost.crt" --dry-run="client" -o="yaml" >> "$SECRET_FILE"
   fi  

}

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
else
    varhost=$1
    varhost_secret=`echo "$varhost" | sed -r 's#\.#-#g'`
fi

varhost_secret="$varhost_secret-secret-tls"

gen_certificate1 $varhost $varhost_secret

cp ./ingress_tls_template.yaml ./ingress_tls.yaml

replace_tag_in_file ./ingress_tls.yaml "<tls-host>" $varhost 
replace_tag_in_file ./ingress_tls.yaml "<tls-name>" $varhost_secret 

kubectl create ns demo
kubectl -n demo apply -f ./hello-app-deployment-v1.yaml
kubectl -n demo apply -f ./hello-svc-v1.yaml

# file generated in gen_certificate()
kubectl -n demo apply -f ./$varhost-secrets.yaml

kubectl -n demo apply -f ./ingress_tls.yaml