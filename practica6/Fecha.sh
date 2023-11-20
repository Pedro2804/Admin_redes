#!/bin/bash

fecha1=$(date +%Y-%m-%d)
hora=$(date +%H:%M)
fecha2=$(date --date='2023-09-13' +%Y-%m-%d)
echo "#####Scrip que valida una fecha#####"
echo
echo "Fecha a comparar: $fecha2"

if [ '$fecha1' == '$fecha2' ]
then
	echo "Fecha actual: $fecha"
	echo "Hora actual: $hora"
else
	echo "ERROR... No es la fecha"
fi
