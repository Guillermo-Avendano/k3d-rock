#!/bin/bash
# Author: Guilllermo Avendaño
# Cretion Date: 12/15/2023

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

cp -r /home/mobius/templates/asg/* /home/mobius/asg/

PRINTAGENT_TEMPLATE_CONFIG_FILE=/home/mobius/asg/printagent/config/application.template.yaml
PRINTAGENT_CONFIG_FILE=/home/mobius/tomcat/webapps/printagent/WEB-INF/classes/application.yaml

cp $PRINTAGENT_TEMPLATE_CONFIG_FILE $PRINTAGENT_CONFIG_FILE
                
# replace all the possible parameters 
replace_tag_in_file $PRINTAGENT_CONFIG_FILE "<PRINTAGENT_DB_HOST>" $PRINTAGENT_DB_HOST
replace_tag_in_file $PRINTAGENT_CONFIG_FILE "<PRINTAGENT_DB_PORT>" $PRINTAGENT_DB_PORT
replace_tag_in_file $PRINTAGENT_CONFIG_FILE "<PRINTAGENT_DB_USER>" $PRINTAGENT_DB_USER
replace_tag_in_file $PRINTAGENT_CONFIG_FILE "<PRINTAGENT_DB_PASS>" $PRINTAGENT_DB_PASS

cd /home/mobius/tomcat/bin

./catalina.sh run
