#!/bin/bash
if [ -f ".env" ]; then

  source ".env" 
fi

# Directorio donde se encuentran los archivos
directorio=$INPUT_DIR/ok

# Patrón de búsqueda
patron="*_*_*_*_*_*.txt"

# Crear un directorio para almacenar el archivo de salida
directorio_salida="${directorio}/archivos_procesados"
mkdir -p "${directorio_salida}"

# Archivo de salida acumulado
archivo_salida="${directorio_salida}/output.txt"
echo "Archivos procesados:" > "${archivo_salida}"

# Iterar sobre los archivos que coinciden con el patrón
for archivo in "${directorio}/${patron}"; do
    # Obtener las partes del nombre de archivo
    nombre_archivo=$(basename "${archivo}")
    IFS="_" read -r P1 P2 P3 P4 P5 P6 <<<"${nombre_archivo}"

    # Verificar si coinciden las partes requeridas
    if [ -n "${P1}" ] && [ -n "${P2}" ] && [ -n "${P3}" ] && [[ "${P4}" =~ ^[0-9]{8}$ ]] && [[ "${P5}" =~ ^[0-9]{6}$ ]] && [[ "${P6}" =~ ^[0-9]$ ]]; then
        # Completar P6 con ceros a la izquierda hasta tener 3 dígitos
        P6=$(printf "%03d" "${P6}")

        # Agregar información al archivo de salida
        echo "Archivo origen: ${nombre_archivo}" >> "${archivo_salida}"
        echo "P1: ${P1}" >> "${archivo_salida}"
        echo "P2: ${P2}" >> "${archivo_salida}"
        echo "P3: ${P3}" >> "${archivo_salida}"
        echo "P4 (Fecha): ${P4}" >> "${archivo_salida}"
        echo "P5 (Hora): ${P5}" >> "${archivo_salida}"
        echo "P6 (Dígito): ${P6}" >> "${archivo_salida}"
        echo "" >> "${archivo_salida}"
    fi
done

echo "Proceso completado. Resultados en: ${archivo_salida}"
