#!/bin/bash

SEGUNDOS_ESPERA=10
while true; do
  # Ejecutar el script principal
  ./acreate.v2.sh

  # "$SEGUNDOS_ESPERA" antes de la próxima ejecución
  sleep $SEGUNDOS_ESPERA
done
