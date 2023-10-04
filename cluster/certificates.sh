#!/bin/sh
source "$kube_dir/env.sh"
source "$kube_dir/cluster/common.sh"

gen_certificate(){
   if [[ $# -eq 0 ]] ; then
      echo "No arguments supplied"
   else
      varhost=$1
   fi

   cert_directory="$kube_dir/cluster/cert"
   
   cert_file="$cert_directory/$varhost-secrets.yaml"
    
   if [ ! -f $cert_file ]; then
      openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "$cert_directory/$varhost.key" -out "$cert_directory/$varhost.crt" -subj "/CN=$varhost" -addext "subjectAltName=DNS:$varhost" -addext 'extendedKeyUsage=serverAuth,clientAuth'
      mycrt="$(cat $cert_directory/$varhost.crt | base64)"
      mykey="$(cat $cert_directory/$varhost.key | base64)"
      mycrt=$(echo $mycrt | tr -d ' ')
      mykey=$(echo $mykey | tr -d ' ')

      varhost_secret=`echo $varhost" | sed -r 's/\./-/g'`

      SECRET_FILE=$cert_directory/$varhost-secrets.yaml
      
      echo -e "apiVersion: v1\nkind: Secret\ndata:\n  tls.crt: #CRT#\n  tls.key: #KEY#\nmetadata:\n  name: #NAME#-secret-tls\ntype: kubernetes.io/tls" > $SECRET_FILE

      replace_tag_in_file $SECRET_FILE "#CRT#" $mycrt;
      replace_tag_in_file $SECRET_FILE "#KEY#" $mykey;
      replace_tag_in_file $SECRET_FILE "#NAME#" $varhost_secret;

   fi  

}