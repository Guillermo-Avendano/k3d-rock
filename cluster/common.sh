#!/bin/bash

command_exists() {
	[ -x "$1" ] || command -v $1 >/dev/null 2>/dev/null
}

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

highlight_message() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}********************************************${reset}"
    echo "${yellow}**${reset} $1 "
    echo "${yellow}********************************************${reset}"
}

info_message() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}>>>>>${reset} $1"
}

error_message() {
    local yellow=`tput setaf 3`
    local red=`tput setaf 1`
    local reset=`tput sgr0`

    echo -e "\r"
    echo "${yellow}>>>>>${reset} ${red} Error: $1${reset}"
}

info_progress_header() {
    local yellow=`tput setaf 3`
    local reset=`tput sgr0`

    echo -e "\r"
    echo -n "${yellow}>>>>>${reset} $1"
}

info_progress() {
    echo -n "$1"
}

detect_os() {
    case "$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) }' /etc/*-release 2> /dev/null)" in
      *debian*)    OS="debian";; # WSL2
      *ubuntu*)    OS="debian";;
      *rhel*)      OS="rhel";;   # Red Hat
      *centos*)    OS="centos";;
      Darwin*)     OS="darwin";;
      *)           OS="UNKNOWN"
    esac
}	

ask_binary_question() {
    # $1 is the question that will be diplayed.
    # $2 if the quiet mode value (true or false)
    local answer="Y"

    if [ "$2" == "false" ]; then
        while true; do
            read -p "$1 " yn
            case $yn in
                [Yy]* ) answer="Y"; break;;
                [Nn]* ) answer="N"; break;;
                * );;
            esac
        done
    fi
    echo "$answer"
}

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

      varhost_secret=`echo "$varhost" | sed -r 's#\.#-#g'`

      SECRET_FILE=$cert_directory/$varhost-secrets.yaml
      
      echo -e "apiVersion: v1\nkind: Secret\ndata:\n  tls.crt: #CRT#\n  tls.key: #KEY#\nmetadata:\n  name: #NAME#-secret-tls\ntype: kubernetes.io/tls" > $SECRET_FILE

      replace_tag_in_file $SECRET_FILE "#CRT#" $mycrt;
      replace_tag_in_file $SECRET_FILE "#KEY#" $mykey;
      replace_tag_in_file $SECRET_FILE "#NAME#" $varhost_secret;

   fi  

}