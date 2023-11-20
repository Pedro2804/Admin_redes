#!/bin/bash
clear
echo "####################CRAER NUEVO USUARIO####################";
echo

max=0;

if [ $(whoami) = root ]; then
	while true; do
		echo "Ingresa un nuevo usuario";
		read username;
		echo
		dir="/home/$username";
		shell="/bim/bash";
		if [ -d "/home/$username" ] || [ -z  "$username" ]; then
			clear
			echo "Error!!!... Ya existe el usuario y no debe ser vacío";
			echo
			echo "ENTER para continuar";
			read
			clear
		else
			uid=$(awk -F: -v max="$max" '{ if ($3 <= 1100 && $3 > max) max = $3 } END { print max+1 }' /etc/passwd);
			echo "UID asignado: $uid";
			echo
			echo "Comentario";
			read comentario;
			echo
			echo "Directorio home asignado: $dir";
			echo
			echo "SHELL: $shell";
			echo
			echo "ENTER para continuar...";
			read
			while true; do
				clear
				echo "Ingrese contraseña";
				read -s passwd;
				echo
				echo "Confirmar contraseña";
				read -s passwd2;
				echo
				if [ "$passwd" != "$passwd2" ]; then
					echo "ERROR!... Las contraseñas no coinciden";
					echo
					echo "ENTER para continuar...";
					read
				else
					break;
				fi
			done
			regex="^[0-9]{4}-[0-9]{2}-[0-9]{2}$";
			echo "Ultimo cambio de contraseña";
			read lastchg;
			echo
			echo "Min";
			read min;
			echo
			echo "Max";
			read max;
			echo
			echo "Warm";
			read warm;
			echo
			echo "Inactive";
			read inactive;
			echo
			while true; do
				echo "Ingrese fecha de expiración (YYYY-MM-DD)";
				read expire;
				echo
				if [[ $expire =~ $regex ]]; then
    					echo "La fecha ingresada no es válida. Asegúrese de seguir el formato YYYY-MM-DD.";
					echo
				else
    					break;
				fi
			done
			echo
			echo "ENTER para continuar...";
			read
			clear
			echo "Ingrese el nombre del grupo (solo ENTER se le asigna el nombre de usuario)";
			read namegroup;

			if [ -z "$namegroup" ]; then
				namegroup=$username;
			fi

			while true; do
				echo
				echo "Ingrese GID (solo ENTER se le asigna la UID)";
				read gid;

				if [ -z "$gid" ]; then
					gid=$uid;
				fi

				if [ $gid -gt 1100 ] || [ $gid -lt 1000 ]; then
					echo "	ERROR!!!... El GID debe ser mayor a 999 y menor a 1100";
				else
					validar=$(awk -F: -v auxgid="$gid" '{ if ($3 == auxgid) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar" ]; then
						echo "Ya existe un grupo con ese GID";
					else
						break;
					fi
				fi
			done;
			echo
			echo "--- En /etc/passwd";
                	echo "$username:x:$uid:$gid:$comentario:$dir:$shell";
			echo
			echo "-- En /etc/group";
			echo "$namegroup:x:$gid:$username";
			echo
			if [ -z "$passwd" ]; then
				hashed_passwd="!";
			else
				hashed_passwd=$(echo -n "$passwd" | sha256sum | awk '{print $1}');
			fi
			echo "---En /etc/shadow";
			echo "$username:$hashed_passwd:$lastchg:$min:$max:$warm:$inactive:$expire";
			echo
			break;
		fi
	done
else
        echo "No tienes permisos para crear un nuevo usuario";
fi
