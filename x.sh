#!/bin/bash

kube_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -d "$kube_dir" ] || {
    echo "FATAL: no current dir (maybe running in zsh?)"
    exit 1
}

file_env=$kube_dir/.env  

# Verify if the file
if [ -e "$file_env" ]; then

  file_env_filter=$(grep -vE '^\s*$|^\s*#' "$file_env")
  file_env_clean=$(echo "$file_env_filter" | sed 's/[[:space:]]*$//')

  # Iterate line by line
  while IFS= read -r line_env; do
    echo $line_env
    export $line_env  
  done <<< $file_env_clean
else
  echo "File $file_env do not exist."
fi