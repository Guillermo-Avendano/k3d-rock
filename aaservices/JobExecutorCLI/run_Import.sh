#!/bin/bash

set -Eeuo pipefail

java -jar aas-cli-11.1.2.jar -jobName ImportDB $@


