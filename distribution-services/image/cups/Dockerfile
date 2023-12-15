# Use the official CUPS image as the base image
# Use the official Debian Buster Slim image as base
FROM debian:buster-slim

# Argumentos para el usuario y la contraseña de CUPS
ARG CUPS_USER=mobius
ARG CUPS_PASSWORD=mobius

# Instala el paquete CUPS
RUN apt-get update && \
    apt-get install -y cups && \
    rm -rf /var/lib/apt/lists/*

# Agrega el usuario 'cups' al grupo 'lpadmin'
RUN useradd -G lpadmin $CUPS_USER

# Elimina los archivos de configuración existentes
RUN rm -f /etc/cups/cupsd.conf /etc/cups/printers.conf

# Configura CUPS para aceptar conexiones desde cualquier dirección IP
RUN sed -i 's/Listen localhost:631/Port 631\nListen 0.0.0.0:631/' /etc/cups/cupsd.conf

# Instala una impresora virtual para PDF
RUN apt-get update && \
    apt-get install -y printer-driver-cups-pdf && \
    rm -rf /var/lib/apt/lists/*

# Crea un directorio para almacenar las impresiones en PDF
RUN mkdir /output_directory
RUN chmod 777 /output_directory

# Configura la impresora virtual para dirigir las impresiones al directorio especificado
RUN echo "CUPS-PDF:\tPDF\tVirtual_PDF_Printer" >> /etc/cups/printers.conf && \
    echo "<Printer PDF>" >> /etc/cups/printers.conf && \
    echo "  Info PDF Printer" >> /etc/cups/printers.conf && \
    echo "  DeviceURI cups-pdf:/output_directory" >> /etc/cups/printers.conf && \
    echo "  State Idle" >> /etc/cups/printers.conf && \
    echo "</Printer>" >> /etc/cups/printers.conf

# Agrega un usuario a CUPS
RUN echo "${CUPS_USER}:${CUPS_PASSWORD}" | chpasswd

# Expone el puerto 631 para las conexiones de CUPS
EXPOSE 631

# Inicia el servicio CUPS
CMD ["/usr/sbin/cupsd", "-f"]
