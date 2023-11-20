#!/bin/bash
echo "Ciclo Until"
echo
i=1
until [ $i = 6 ]
do
	echo "welcome $i times."
	i=$(( i+1 ))
done


