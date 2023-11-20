#!/bin/bash
clear

echo "##########RESPALDO##########";
echo

echo "Capturar fecha";
fecha=$(date +%Y-%m-%d); #Almacenamos la fecha actual en la variable fecha
echo $fecha;		 #Mostramos la fecha en pantalla
read			 #Realizamos una pausa
clear
echo "Haciendo tar";
tar -cvf /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script/respaldo$fecha.tar /etc #Comando para empaquetar que tiene como parametros
#La ruta donde vamos a guardar el Tar junto con el nombre del directorio rar que se va a crear - lo que se va a empaquetar
echo
echo "Fin tar";
echo
echo "ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script";
ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script
echo
echo "ENTER para continuar";
read
clear
echo "Comprimiendo con bzip2";
tar -cjvf /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script/respaldo$fecha.tar.bz2 /etc #Comando para crear un contenedor comprimido con bzip2
#Ruta donde vamos a guardar el contenedor junto con el nombre del directorio que se va a crear - lo que se va a comprimir
echo
echo "Fin bzip2";
echo
echo "ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script";
ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script
echo
echo "ENTER para continuar";
read
clear
echo "Creando zip";
zip -r /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script/respaldo$fecha.zip /etc #Comando para crear contenedor comprimido zip
#Ruta donde vamos a guardar el contenedor junto con el nombre del directorio que se va a crear - lo que se va a comprimir
echo
echo "Fin zip";
echo
echo "ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script";
ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script
echo
echo "ENTER para continuar";
read
clear
echo "Crear directorio respald1 en /home";
mkdir /home/respaldo1 #Creamos un nuevo directorio en home que se va a llamar respaldo 1
echo
echo "ls /home";
ls /home
echo
echo "ENTER para continuar";
read
clear
echo "Copiamos el contenedor tar que creamos al directorio /home/respaldo1";
cp /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script/respaldo$fecha.tar /home/respaldo1 #Copiamos el contenedor Tar a respaldo1
echo
echo "ls /home/respaldo1";
ls /home/respaldo1
echo
echo "ENTER para continuar";
read
clear
echo "Limpiando (eliminamos el contenedor tar que creamos)";
rm -rf /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script/respaldo$fecha.tar #Eliminados el contenedor tar que creamos y nos quedamos con la copia
#almacenada en /home/respaldo1
echo
echo "ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script";
ls /home/cipher/Documentos/memoria/Archivos/respaldos/respaldo_script
echo
echo "ENTER para continuar";
read
clear
echo "Nos quedamos con la copia del contenedor que esta en /home/respaldo1";
echo
echo "ls /home/respaldo1";
ls /home/respaldo1
echo
echo "Fin";
echo
