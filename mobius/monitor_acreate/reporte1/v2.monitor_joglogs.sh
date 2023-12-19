#!/bin/bash

SEGUNDOS_ESPERA=10
while true; do

  # Consolida DDs de un mismo JOB
  ./v2.consolida.sh

  # Ejecutar el script principal
  ./v2.acreate.sh

  # "$SEGUNDOS_ESPERA" antes de la próxima ejecución
  sleep $SEGUNDOS_ESPERA
done
