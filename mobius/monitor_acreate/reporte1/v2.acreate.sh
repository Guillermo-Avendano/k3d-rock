#!/bin/bash

SCRIPT_NAME="acreate.sh"

# Directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar variables desde el archivo .env
if [ -f "$SCRIPT_DIR/.env" ]; then

  source "$SCRIPT_DIR/.env" 

  # Crea directorio LOG_DIR si no existe
  if [ ! -d "$LOG_DIR" ]; then
    if [ -z "$LOG_DIR" ]; then
      LOG_DIR=$INPUT_DIR/log   
    fi
    mkdir -p $LOG_DIR;
  fi 

  LOG_FILE=$LOG_DIR/LOG_$PREFIX.log
  # Si no existe el archivo de log lo crea
  if [ ! -e "$LOG_FILE" ]; then
     touch $LOG_FILE
  fi

  MAX_SIZE=$((1024 * 1024))  # Tamaño máximo en bytes (1 MegaByte)
  
  # Verificar el tamaño del archivo
  current_size=$(wc -c < "$LOG_FILE")

  if [ "$current_size" -ge "$MAX_SIZE" ]; then
      # Crear una copia del archivo con un nombre que incluye el timestamp
      timestamp=$(date +"%Y%m%d_%H%M%S")
      cp "$LOG_FILE" "$LOG_DIR/LOG_${PREFIX}_${timestamp}.log"

      # Vaciar el archivo original
      echo -n > "$LOG_FILE"
  fi
fi

# Crea directorio de PROCESADOS_OK si no existe donde van los archivos ya procesados con error
if [ ! -d "$PROCESADOS_OK" ]; then
   if [ -z "$PROCESADOS_OK" ]; then
  	  PROCESADOS_OK=$INPUT_DIR/ok   
	 fi
   mkdir -p $PROCESADOS_OK;
fi 

# Crea directorio de PROCESADOS_ERR si no existe donde van los archivos ya procesados con error
if [ ! -d "$PROCESADOS_ERR" ]; then
   if [ -z "$PROCESADOS_ERR" ]; then
  	  PROCESADOS_ERR=$INPUT_DIR/err   
	 fi
   mkdir -p $PROCESADOS_ERR;
fi 

# Obtener el nombre del directorio actual
CURRENT_DIR=$(basename "$SCRIPT_DIR")

# Definir el nombre del archivo de bloqueo
LOCK_FILE="/tmp/$SCRIPT_NAME.$PREFIX.lock"

# Crear timestamp con el formato especificado
# Obtener timestamp antes de ejecutar el comando
TM_LOG=$(date "+%Y-%m-%d %H:%M:%S.%3N")

# Verificar si el script ya está en ejecución para el directorio actual
if [ -e "$LOCK_FILE" ] && kill -0 $(cat "$LOCK_FILE") 2>/dev/null; then
  echo "$TM_LOG [INFO] El script ya ejecutando en $CURRENT_DIR. Saliendo." >> $LOG_FILE
  exit 1
fi

# Crear el archivo de bloqueo
echo $$ > "$LOCK_FILE" 

# Obtener el nombre del primer archivo .TXT en INPUT_DIR
FILENAME=$(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.lst" -print -quit)

# Verificar si se encontró un archivo con $EXTENSION
if [ -z "$FILENAME" ]; then
  rm "$LOCK_FILE"
  exit 1
fi

#-----------------
# Obtener la fecha y hora actual en formato UNIX timestamp
fecha_actual=$(date +%s)

# Obtener la fecha y hora de modificación del archivo en formato UNIX timestamp
fecha_modificacion=$(stat -c %Y "${FILENAME}")

# Calcular la diferencia en segundos
diferencia=$((fecha_actual - fecha_modificacion))

limite=10

if [ $diferencia -le $limite ]; then
    echo "$TM_LOG [INFO] $FILENAME esta siendo modificado, no será procesado aún." >> $LOG_FILE
    #echo "El archivo ha sido modificado en los últimos $limite segundos. Saliendo del script."
    exit 1
fi
#-----------------

FILENAME_SHORT=$(basename "$FILENAME")
echo "$TM_LOG [INFO] Procesando: $FILENAME" >> $LOG_FILE

# Ejecutar acreate.sh con redirección de salida a un archivo de log

PATH=/opt/asg/java/bin:$PATH
java -D"log4j.configurationFile=${MOBIUS_REMOTE_CLI_PATH}/BOOT-INF/classes/log4j2.yaml" -jar ${MOBIUS_REMOTE_CLI_PATH}/acreate-cli.jar acreate -s Mobius -u ADMIN -f "$FILENAME" -m i -v 2 > "$LOG_DIR/$FILENAME_SHORT.log" 2>&1

# Obtener timestamp después de ejecutar el comando
TM_LOG_END=$(date "+%Y-%m-%d %H:%M:%S.%3N")

# Calcular el tiempo transcurrido
start_seconds=$(date -d "$TM_LOG" +"%s")
end_seconds=$(date -d "$TM_LOG_END" +"%s")
elapsed_seconds=$((end_seconds - start_seconds))
# Verificar si el comando fue exitoso

if [ $? -ne 0 ] || grep -iq "Error" "$LOG_DIR/$FILENAME_SHORT.log"; then
   echo "$TM_LOG_END [ERROR]"
   cat "$LOG_DIR/$FILENAME_SHORT.log" >> $LOG_FILE
   mv -f "$FILENAME" "$PROCESADOS_ERR/$FILENAME_SHORT"
   echo "$TM_LOG_END [INFO] moviendo $FILENAME_SHORT a $PROCESADOS_ERR" >> $LOG_FILE
else
  mv -f "$FILENAME" "$PROCESADOS_OK/$FILENAME_SHORT"
  echo "$TM_LOG_END [INFO] moviendo $FILENAME_SHORT a $PROCESADOS_OK" >> $LOG_FILE
fi

# echo "$TM_LOG_END [INFO] Tiempo: $elapsed_seconds segundos" >> $LOG_FILE
# borra archivo de log transitorio
rm $LOG_DIR/$FILENAME_SHORT.log 

# Eliminar el archivo de bloqueo
rm "$LOCK_FILE"
