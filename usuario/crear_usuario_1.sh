#!/bin/bash

source interfaz.sh;

trap 'abortar' INT TSTP

clear
max=0;

#Verificar si es root
if [ $(whoami) = root ]; then
	main 76 "CREAR NUEVO USUARIO";
	while true; do

		#Determinar los campos para el archivo /etc/passwd.
		label 12 70 "> Ingresa un nuevo usuario:"; #Nombre usuario
		move_cursor 11 97;
		read username;

		#Verificamos si ya existe el usuario o no.
		validar_u=$(awk -F: -v aux_u="$username" '{ if ($1 == aux_u) v = "si" }END{ print v }' /etc/passwd);
		
		if [ -n "$validar_u" ]; then
			error 70 "Ya existe el usuario" "CREAR NUEVO USUARIO" 76;
		elif [ -z  "$username" ]; then
			error 66 "Ingrese un nombre de usuario" "CREAR NUEVO USUARIO" 76;
		elif ! [[ $username =~ ^[a-z0-9_]{1,32}$ ]]; then
			error 55 "Ingrese datos alfanuméricos y minúsculas sin espacio" "CREAR NUEVO USUARIO" 76;
		else

			#Directorio home
			dir="/home/$username";

			#Shell
			shell="/bin/bash";

			#UID: Se asigna en automático.
			uid=$(awk -F: -v max="$max" '{ if ($3 <= 1100 && $3 > max) max = $3 } END { print max+1 }' /etc/passwd);

			#Comentario
			label 14 70 "> UID asignado: $uid";
			label 16 70 "> Comentario: ";
			move_cursor 15 83;
			read comentario;

			if [ -z "$comentario" ]; then
				comentario="$username";
			fi

			label 18 70 "> Directorio home asignado: $dir";
			label 20 70 "> SHELL: $shell";
			enter 24;
			clear

			#Determinar los campos para el archivo /etc/shadow:
			main 80 "CONTRASEÑA";
			while true; do

				#Contraseña en texto plano
				label 12 68 "> Ingrese contraseña para '$username':";
				move_cursor 11 102;
				read -s passwd;
				label 13 68 "> Confirmar contraseña:";
				move_cursor 12 91;
				read -s passwd2;
				if [ "$passwd" != "$passwd2" ]; then
					error 68 "Las contraseñas no coinciden" "CONTRASEÑA" 80;
				else
					break;
				fi
			done

			fecha_ac=$(date +%s);
			lastchg=$(((fecha_ac / 86400) - 1));
			aux_last=$(date -d "@$fecha_ac" "+%Y-%m-%d");

			while true; do

				#Último cambio
				label 15 68 "> Último cambio de contraseña: $aux_last";

				#Puede cambiar
				label 17 68 "> Días mínimos entre cambio de contraseña (0):";
				read min;
				if [ -z "$min" ]; then
					min=0;
					break;
				else
					if [[ $min =~ ^[0-9]*$ ]]; then
						break;
					else
						error 70 "Ingrese datos numéricos" "CONTRASEÑA" 80;
						label 12 68 "> Ingrese contraseña para '$username':";
						label 13 68 "> Confirmar contraseña:";
					fi
				fi
			done

			while true; do

				#Debe cambiar
				label 19 68 "> Fecha de expiración de la contraseña (YYYY-MM-DD):";
				move_cursor 18 120;
				read max;
				if [ -z "$max" ]; then
					max=99999;
					break;
				elif [[ $max =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
					if date -d "$max" &>/dev/null; then
						fecha_ingresada=$(date -d "$max" +%s);
						if [[ $fecha_ingresada -gt $fecha_ac ]]; then
							aux_max=$(date -d "@$fecha_ingresada" "+%Y-%m-%d");
							max=$(((fecha_ingresada / 86400)));
							break;
						else
							error 70 "Ingrese una fecha válida" "CONTRASEÑA" 80;
						fi
					else
						error 70 "Ingrese una fecha válida" "CONTRASEÑA" 80;
					fi
				else
					error 63 "Ingrese el formato de fecha (YYYY-MM-DD)" "CONTRASEÑA" 80;
				fi
				label 12 68 "> Ingrese contraseña para '$username':";
				label 13 68 "> Confirmar contraseña:";
				label 15 68 "> Último cambio de contraseña: $aux_last";
				label 17 68 "> Días mínimos entre cambio de contraseña (0): $min";
			done

			while true; do

				#Aviso
				label 21 68 "> Días de aviso antes de que caduque la contraseña (7): "; #Alerta
				move_cursor 20 123;
				read warm;
				if [ -z "$warm" ]; then
					warm=7;
					break;
				else
					if [[ $warm =~ ^[0-9]*$ ]]; then
						break;
					else
						error 65 "Ingrese datos numéricos y positivos" "CONTRASEÑA" 80;
					fi
				fi
				label 12 68 "> Ingrese contraseña para '$username':";
				label 13 68 "> Confirmar contraseña:";
				label 15 68 "> Último cambio de contraseña: $aux_last";
				label 17 68 "> Días mínimos entre cambio de contraseña (0): $min";
				label 19 68 "> Fecha de expiración de la contraseña (YYYY-MM-DD): $aux_max";
			done

			while true; do

				#Caduca
				label 23 68 "> Días antes de deshabilitar la cuenta:"; 
				move_cursor 22 107
				read inactive;

				if [ -z "$inactive" ]; then
					break;
				else
					if [[ $inactive =~ ^[0-9]*$ ]]; then
						break;
					else
						error 65 "Ingrese datos numéricos y positivos" "CONTRASEÑA" 80;
					fi
				fi

				label 12 68 "> Ingrese contraseña para '$username':";
				label 13 68 "> Confirmar contraseña:";
				label 15 68 "> Último cambio de contraseña: $aux_last";
				label 17 68 "> Días mínimos entre cambio de contraseña (0): $min";
				label 19 68 "> Fecha de expiración de la contraseña (YYYY-MM-DD): $aux_max";
				label 21 68 "> Días de aviso antes de que caduque la contraseña (0): $warm";
			done
			enter 25;
			clear

			#Determinar los campos para el archivo /etc/group:
			main 82 "GRUPO";
			while true; do

				#Nombre del grupo
				label 12 58 "> Nombre del nuevo grupo (ENTER para nombre de usuario):";
				move_cursor 11 114;
				read namegroup;

				if [ -z "$namegroup" ]; then
					namegroup=$username;
					break;
				else
					validar_nom=$(awk -F: -v auxnom="$namegroup" '{ if ($1 == auxnom) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar_nom" ]; then
						error 65 "Ya existe un grupo con ese nombre" "GRUPO" 82;
					else
						break;
					fi
				fi
			done

			while true; do

				#GID en automático
				label 14 58 "> Ingrese GID (ENTER se le asigna la UID):";
				move_cursor 13 100;
				read gid;

				if [ -z "$gid" ]; then
					gid=$uid;
					break;
				elif [ $gid -gt 1100 ] || [ $gid -lt 1000 ]; then
					error 62 "El GID debe ser mayor a 1000 y menor a 1100" "GRUPO" 82;
				else
					validar=$(awk -F: -v auxgid="$gid" '{ if ($3 == auxgid) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar" ]; then
						error 65 "Ya existe un grupo con ese GID" "GRUPO" 82;
					else
						break;
					fi
				fi

				label 12 58 "> Nombre del nuevo grupo (ENTER para nombre de usuario): $namegroup";
			done;

			#printf "\n\n\t\t\t--- En /etc/passwd\n";
            #printf "\t\t\t$username:x:$uid:$gid:$comentario:$dir:$shell\n";
			#printf "\n\t\t\t--- En /etc/group\n";
			#printf "\t\t\t$namegroup:x:$gid:$username\n";

			#Encriptar la contraseña
			if [ -z "$passwd" ]; then
				pass="*";
			else
				num_rand=$((3 + RANDOM % 10));
				caracteres="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
				long=${#caracteres};

				for ((i=0; i<$num_rand; i++)); do
					index_rand=$((RANDOM % long));
					salt+="${caracteres:$index_rand:1}";
				done

				pass=$(openssl passwd -5 -salt "$salt" "$passwd");
			fi
			#printf "\n\t\t\t--- En /etc/shadow\n";
			#printf "\t\t\t$username:$pass:$lastchg:$min:$max:$warm:$inactive::\n\n";

			#escribir las líneas a los archivos correspondientes
			echo "$username:x:$uid:$gid:$comentario:$dir:$shell" >> /etc/passwd;
			echo "$namegroup:x:$gid:$username" >> /etc/group;
			echo "$username:$pass:$lastchg:$min:$max:$warm:$inactive::" >> /etc/shadow;

			mkdir /home/$username #Crear el directorio home
			chmod a-rwx /home/$username #Quitar todos los permisos
			chmod u=rwx,g=rx,o= /home/$username #conceder los permisos necesarios
			find /etc/skel -maxdepth 1 -name ".*" -exec cp -r {} /home/$username/ \; #Copiar los archivos del directorio skel
			chown -R $username:$namegroup /home/$username #Agregar el usuario al nuevo grupo

			finish 68 "-----USUARIO CREADO EXITOSAMENTE-----";
			#chage -l $username

			#find /etc/skel -mindepth 1 -maxdepth 1 \( ! -name '.' -a ! -name '..' \) -exec cp -r {} /home/$username/ \;
			#cp -r /etc/skel/.* /home/$username
			break;
		fi
	done
else
        printf "No tienes permisos para crear un nuevo usuario\n";
fi

exit 0;