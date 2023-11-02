#!/bin/bash
source /opt/obent/setenv.sh

/lib/ld-linux.so.2 /opt/obent/obstartserver  -connection servertcp 

tail -f /dev/null