#!/bin/bash

source interfaz.sh;

epoca_unix(){
	local fecha_ac=$(date +%s);
	local epoca=$(date -d "1970-01-01" +%s);
	local seg=$((fecha_ac - epoca_unix));
	local res=$((seg / (24 * 60 * 60)));

	local info=("$fecha_ac" "$res");
	echo "${info[@]}";
}

clear
max=0;

if [ $(whoami) = root ]; then
	while true; do
		main 76 "CREAR NUEVO USUARIO";
		label 6 70 "> Ingresa un nuevo usuario: ";
		move_cursor 5 97;
		read username;
		validar_u=$(awk -F: -v aux_u="$username" '{ if ($1 == aux_u) v = "si" }END{ print v }' /etc/passwd);
		
		if [ -n "$validar_u" ]; then
			error 70 "Ya existe el usuario" "CREAR NUEVO USUARIO" 76;
		elif [ -z  "$username" ]; then
			error 66 "Ingrese un nombre de usuario" "CREAR NUEVO USUARIO" 76;
		elif ! [[ $username =~ ^[a-z0-9_]{1,32}$ ]]; then
			error 55 "Ingrese datos alfanuméricos y minúsculas sin espacio" "CREAR NUEVO USUARIO" 76;
		else
			dir="/home/$username";
			shell="/bin/bash";
			uid=$(awk -F: -v max="$max" '{ if ($3 <= 1100 && $3 > max) max = $3 } END { print max+1 }' /etc/passwd);
			label 8 70 "> UID asignado: $uid";
			label 10 70 "> Comentario: ";
			move_cursor 9 83;
			read comentario;

			if [ -z "$comentario" ]; then
				comentario="$username";
			fi

			label 12 70 "> Directorio home asignado: $dir";
			label 14 70 "> SHELL: $shell";
			enter 18;
			while true; do
				clear
				main 80 "CONTRASEÑA";
				label 6 68 "> Ingrese contraseña para '$username': ";
				move_cursor 5 102;
				read -s passwd;
				label 7 68 "> Confirmar contraseña: ";
				move_cursor 6 91;
				read -s passwd2;
				if [ "$passwd" != "$passwd2" ]; then
					error 68 "Las contraseñas no coinciden" "CONTRASEÑA" 80;
				else
					break;
				fi
			done

			result=($(epoca_unix));
			lastchg=${result[1]};
			aux=$(date -d "@$((lastchg * 86400))" "+%Y-%m-%d");
			fecha_ac=${result[0]};

			while true; do
				main 80 "CONTRASEÑA";
				label 9 68 "> Último cámbio de contraseña: $aux";
				label 6 68 "> Ingrese contraseña para '$username': ";
				label 7 68 "> Confirmar contraseña: ";
				label 11 68 "> Días mínimos entre cambio de contraseña (0): ";
				read min;
				if [ -z "$min" ]; then
					min=0;
					break;
				else
					if [[ $min =~ ^[0-9]*$ ]]; then
						break;
					else
						error 70 "Ingrese datos numéricos" "CONTRASEÑA" 80;
					fi
				fi
			done

			while true; do
				label 13 68 "> Fecha de expiración de la contraseña (YYYY-MM-DD): ";
				move_cursor 12 120;
				read max;
				if [ -z "$max" ]; then
					max=99999;
					break;
				elif [[ $max =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
					if date -d "$max" &>/dev/null; then
						fecha_ingresada=$(date -d "$max" +%s);
						if [[ $fecha_ingresada -gt $fecha_ac ]]; then
							max=$fecha_ingresada;
							aux=$((max - fecha_ac))
							max=$(((aux / (24 * 60 * 60) + 1)))
							break;
						else
							error "Ingrese una fecha válida\n";
						fi
					else
						error "Ingrese una fecha válida.\n";
					fi
				else
					error "Ingrese el formato de fecha (YYYY-MM-DD)\n"
				fi
			done

			while true; do
				printf "\n\t\t\tNúmero de días de aviso antes de que caduque la contraseña (ENTER para asignar 0): "; #Alerta
				read warm;
				if [ -z "$warm" ]; then
					warm=0;
					break;
				else
					if [[ $warm =~ ^[0-9]*$ ]]; then
						break;
					else
						error "Ingrese datos numéricos\n";
					fi
				fi
			done

			while true; do
				printf "\n\t\t\tNúmero de días a transcurrir antes de deshabilitar la cuenta: ";
				read inactive;
				if [ -z "$inactive" ]; then
					break;
				else
					if [[ $inactive =~ ^[0-9]*$ ]]; then
						break;
					else
						error "Ingrese datos numéricos\n";
					fi
				fi
			done
			clear
			while true; do
				printf "\n\t\t\tIngrese el nombre del grupo (solo ENTER se le asigna el nombre de usuario): ";
				read namegroup;

				if [ -z "$namegroup" ]; then
					namegroup=$username;
					break;
				else
					validar_nom=$(awk -F: -v auxnom="$namegroup" '{ if ($1 == auxnom) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar_nom" ]; then
						error "Ya existe un grupo con ese nombre\n";
					else
						break;
					fi
				fi
			done

			while true; do
				printf "\n\t\t\tIngrese GID (solo ENTER se le asigna la UID): ";
				read gid;

				if [ -z "$gid" ]; then
					gid=$uid;
				fi

				if [ $gid -gt 1100 ] || [ $gid -lt 1000 ]; then
					error "El GID debe ser mayor a 1000 y menor a 1100\n";
				else
					validar=$(awk -F: -v auxgid="$gid" '{ if ($3 == auxgid) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar" ]; then
						error "Ya existe un grupo con ese GID\n";
					else
						break;
					fi
				fi
			done;

			printf "\n\n\t\t\t--- En /etc/passwd\n";
            printf "\t\t\t$username:x:$uid:$gid:$comentario:$dir:$shell\n";
			printf "\n\t\t\t--- En /etc/group\n";
			printf "\t\t\t$namegroup:x:$gid:$username\n";

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

				#hashed_passwd=$(echo -n "$passwd2" | sha256sum | awk '{print $1}');
				pass=$(openssl passwd -5 -salt "$salt" "$passwd");

				#alg=5;
				#pass="\$${alg}\$${salt}\$${hashed_passwd}/";
			fi
			printf "\n\t\t\t--- En /etc/shadow\n";

			printf "\t\t\t$username:$pass:$lastchg:$min:$max:$warm:$inactive::\n\n";

			echo "$username:x:$uid:$gid:$comentario:$dir:$shell" >> /etc/passwd;
			echo "$namegroup:x:$gid:$username" >> /etc/group;
			echo "$username:$pass:$lastchg:$min:$res:$warm:$inactive::" >> /etc/shadow;

			mkdir /home/$username
			chmod a-rwx /home/$username
			chmod u=rwx,g=rx,o= /home/$username
			find /etc/skel -maxdepth 1 -name ".*" -exec cp -r {} /home/$username/ \;
			chown -R $username:$namegroup /home/$username
			chage -l $username
			#find /etc/skel -mindepth 1 -maxdepth 1 \( ! -name '.' -a ! -name '..' \) -exec cp -r {} /home/$username/ \;
			#cp -r /etc/skel/.* /home/$username
			break;
		fi
	done
else
        error "No tienes permisos para crear un nuevo usuario\n";
fi

#$5$ySze$ScWsm1fAmgeXDdsn7qFMAF5cGxacxLovhX8DNk1H0g/
#$5$ySze$83542007f718e172f71de03400cba22f22369b45b0f93a430f617104e36e7d5d -n