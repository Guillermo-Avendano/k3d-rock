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

  if [ ! -e "$LOG_DIR/$PREFIX.log" ]; then
     touch $LOG_DIR/$PREFIX.log
  fi
  
  echo "" $FILENAME >> $LOG_DIR/$PREFIX.log
  echo "Parametros:" $FILENAME >> $LOG_DIR/$PREFIX.log
  cat "$SCRIPT_DIR/.env" >> $LOG_DIR/$PREFIX.log
  echo ""  >> $LOG_DIR/$PREFIX.log
else
  echo "Error: No se encontró el archivo .env en el directorio $SCRIPT_DIR" >> $LOG_DIR/$PREFIX.log
  exit 1
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

# Verificar si el script ya está en ejecución para el directorio actual
if [ -e "$LOCK_FILE" ] && kill -0 $(cat "$LOCK_FILE") 2>/dev/null; then
  echo "El script ya se está ejecutando en el directorio $CURRENT_DIR. Saliendo." >> $LOG_DIR/$PREFIX.log
  exit 1
fi

# Crear el archivo de bloqueo
echo $$ > "$LOCK_FILE" 

# Crear timestamp con el formato especificado
TM=$(date +"%Y%m%d.%H%M%S")

# Obtener el nombre del primer archivo .TXT en INPUT_DIR
FILENAME=$(find "$INPUT_DIR" -maxdepth 1 -type f -name "$EXTENSION" -print -quit)

# Verificar si se encontró un archivo con $EXTENSION

if [ -z "$FILENAME" ]; then
  echo "No se encontraron archivos $EXTENSION en $INPUT_DIR. Saliendo." >> $LOG_DIR/$PREFIX.log
  rm "$LOCK_FILE"
  exit 1
fi

# Obtener timestamp antes de ejecutar el comando
start_timestamp=$(date +"%Y-%m-%d %H:%M:%S")

FILENAME_SHORT=$(basename "$FILENAME")
echo "" >> $LOG_DIR/$PREFIX.log
echo "Procesando..." $FILENAME >> $LOG_DIR/$PREFIX.log
echo $start_timestamp >> $LOG_DIR/$PREFIX.log

# Ejecutar acreate.sh con redirección de salida a un archivo de log

PATH=/opt/asg/java/bin:$PATH
java -D"log4j.configurationFile=${MOBIUS_REMOTE_CLI_PATH}/BOOT-INF/classes/log4j2.yaml" -jar ${MOBIUS_REMOTE_CLI_PATH}/acreate-cli.jar acreate -s Mobius -u ADMIN -f "$FILENAME" -r $CONTENT_CLASS -c $ARCHIVE_POLICY -v 2 > "$LOG_DIR/$TM.$PREFIX.$FILENAME_SHORT.log" 2>&1

# Obtener timestamp después de ejecutar el comando
end_timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Calcular el tiempo transcurrido
start_seconds=$(date -d "$start_timestamp" +"%s")
end_seconds=$(date -d "$end_timestamp" +"%s")
elapsed_seconds=$((end_seconds - start_seconds))
# Verificar si el comando fue exitoso

if [ $? -ne 0 ] || grep -iq "Error" "$LOG_DIR/$TM.$PREFIX.$FILENAME_SHORT.log"; then
   echo "Error en el comando. Archivo de salida: $LOG_DIR/$TM.$PREFIX.ERR.$FILENAME_SHORT" >> $LOG_DIR/$PREFIX.log
   mv "$LOG_DIR/$TM.$PREFIX.$FILENAME_SHORT.log" "$LOG_DIR/$TM.$PREFIX.ERR.$FILENAME_SHORT.log"
   mv -f "$FILENAME" "$PROCESADOS_ERR/$FILENAME_SHORT"
else
  echo "Comando exitoso. Archivo de salida: $LOG_DIR/$TM.$PREFIX.OK.$FILENAME_SHORT" >> $LOG_DIR/$PREFIX.log
  mv "$LOG_DIR/$TM.$PREFIX.$FILENAME_SHORT.log" "$LOG_DIR/$TM.$PREFIX.OK.$FILENAME_SHORT.log"
  mv -f "$FILENAME" "$PROCESADOS_OK/$FILENAME_SHORT"

fi
echo $end_timestamp >> $LOG_DIR/$PREFIX.log
echo "Tiempo en segundos: $elapsed_seconds" >> $LOG_DIR/$PREFIX.log
echo "-------------" >> $LOG_DIR/$PREFIX.log

# Eliminar el archivo de bloqueo
rm "$LOCK_FILE"
