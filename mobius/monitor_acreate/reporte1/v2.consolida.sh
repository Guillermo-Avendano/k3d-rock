#!/bin/bash

source ".env" 

# Directorio donde se encuentran los archivos
directorio=$INPUT_DIR

# Directorio para almacenar los archivos agrupados
directorio_destino="${directorio}/archivos_agrupados"
mkdir -p "${directorio_destino}"

# Patrón de búsqueda
#patron=".*_.*_.*_.*_.*_.*\.TXT"
patron=".*\.TXT"

# Procesar los archivos y agruparlos por P1, P2, P4 y P5
for archivo in "${directorio}"/*; do
  
    #-----------------
    # Obtener la fecha y hora actual en formato UNIX timestamp
    fecha_actual=$(date +%s)

    # Obtener la fecha y hora de modificación del archivo en formato UNIX timestamp
    fecha_modificacion=$(stat -c %Y "${archivo}")

    # Calcular la diferencia en segundos
    diferencia=$((fecha_actual - fecha_modificacion))

    # 10 minutos
    limite=600
    #-----------------

    # Verificar si el archivo coincide con el patrón y si $diferencia es mayor que $limite
    if [[ "$archivo" =~ $patron ]] && [ $diferencia -gt $limite ]; then
        # Obtener las partes del nombre de archivo

        IFS="_" read -r P1 P2 P3 P4 P5 P6 <<<"$(basename "${archivo%.*}")"

        # Crear una etiqueta única para identificar el grupo
        etiqueta_grupo="${P1}_${P2}_${P4}_${P5}"

        # Crear un archivo de salida para el grupo si no existe
        archivo_grupo="${directorio}/${etiqueta_grupo}.lst"

        # Si no existe el archivo de log lo crea
        if [ ! -e "$archivo_grupo" ]; then
           touch "${archivo_grupo}"
           echo "REPORT-ID=$CONTENT_CLASS, VERSION=${P4}${P5}" >> "${archivo_grupo}"
        fi           

        P6_completo=$(printf "%03d" "$P6")

        nombre_corto=$(basename "$archivo")

        # Agregar información del archivo al archivo de grupo
        echo "FILE=\"${directorio_destino}/${nombre_corto}\", TYPE=TXT, SECTION=\"${P6_completo} ${P3} ${P2}\", ENCODING=UTF-8" >> "${archivo_grupo}"
        echo "TOPIC-ID=JobName, TOPIC-ITEM=${P2}" >> "${archivo_grupo}"
        echo "TOPIC-ID=JobUser, TOPIC-ITEM=${P1}" >> "${archivo_grupo}"
        echo "TOPIC-ID=JobFecha, TOPIC-ITEM=${P4}" >> "${archivo_grupo}"
        echo "TOPIC-ID=JobHora, TOPIC-ITEM=${P5}" >> "${archivo_grupo}"

        # Mover el archivo al directorio de destino
        mv "${archivo}" "${directorio_destino}/"
    fi
done

echo "Proceso completado. Archivos agrupados en: ${directorio_salida} y archivos movidos a: ${directorio_destino}"
