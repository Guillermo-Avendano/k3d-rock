
# Desde el linux que accede al docker con cups
sudo apt-get update
sudo apt-get install cups


sudo nano /etc/cups/client.conf
ServerName tu_direccion_de_impresora:631


sudo service cups restart



lp -d 192.168.0.81:631/Virtual_PDF_Printer my_document.txt