#!/bin/bash

fecha=$(date +%Y-%m-%d)
hora=$(date +%H:%M:%S)

echo "Hola, este es un manejo Script de manejo del tiempo y ciclo until" > segundos.txt
echo "La hora actual es: $hora" >>segundos.txt
echo >>segundos.txt

i=0
until [ $i = 60 ]
do
	echo "$i - La hora actual es: $(date +%H:%M:%S)" >> segundos.txt
	i=$(( i+1 ))
done
