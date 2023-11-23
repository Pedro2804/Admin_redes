#!/bin/bash
enter() {
    printf "\n\t\t\tENTER para continuar";
	read
}

error() {
	local message=$1
    printf "\n\n\t\t\tERROR!... $message";
}

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
		printf "\n\t\t\t####################CREAR NUEVO USUARIO####################\n";
		printf "\n\t\t\tIngresa un nuevo usuario: ";
		read username;
		dir="/home/$username";
		shell="/bin/bash";
		if [ -d "/home/$username" ] || [ -z  "$username" ]; then
			clear
			error "Ya existe el usuario y no debe ser vacío\n";
			enter
			clear
		else
			uid=$(awk -F: -v max="$max" '{ if ($3 <= 1100 && $3 > max) max = $3 } END { print max+1 }' /etc/passwd);
			printf "\n\t\t\tUID asignado: $uid\n";
			printf "\n\t\t\tComentario: ";
			read comentario;
			printf "\n\t\t\tDirectorio home asignado: $dir\n";
			printf "\n\t\t\tSHELL: $shell\n";
			enter
			while true; do
				clear
				printf "\n\t\t\tIngrese contraseña: ";
				read -s passwd;
				printf "\n\t\t\tConfirmar contraseña: ";
				read -s passwd2;
				if [ "$passwd" != "$passwd2" ]; then
					clear
					error "Las contraseñas no coinciden\n";
					enter
				else
					break;
				fi
			done

			result=($(epoca_unix));
			lastchg=${result[1]};
			fecha_ac=${result[0]};

			printf "\n\n\t\t\tÚltimo cámbio de contraseña: $lastchg\n";
			while true; do
				printf "\n\t\t\tNumero minimo de dias para cambiar la contraseña (ENTER para asignar 0): ";
				read min;
				if [ -z "$min" ]; then
					min=0;
					break;
				else
					if [[ $min =~ ^[0-9]*$ ]]; then
						break;
					else
						clear
						error "Ingrese datos numéricos\n";
						enter
						clear
					fi
				fi
			done
			while true; do
				printf "\n\t\t\tFecha de expiración de la contraseña (YYYY-MM-DD): ";
				read max;
				if [[ $max =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
					if date -d "$max" &>/dev/null; then
						fecha_ingresada=$(date -d "$max" +%s);
						if [[ $fecha_ingresada -gt $fecha_ac ]]; then
							max=$fecha_ingresada;
							break;
						else
							clear
							error "Ingrese una fecha válida\n";
							enter
							clear
						fi
					else
						clear
						error "Ingrese una fecha válida.\n";
						enter
						clear
					fi
				else
					clear
					error "Ingrese el formato de fecha (YYYY-MM-DD)\n"
					enter
					clear
				fi
			done

			while true; do
				printf "\n\t\t\tNumero de días antes de la expiración de la contraseña (ENTER para asignar 0): "; #Alerta
				read warm;
				if [ -z "$warm" ]; then
					warm=0;
					break;
				else
					if [[ $warm =~ ^[0-9]*$ ]]; then
						break;
					else
						clear
						error "Ingrese datos numéricos\n";
						enter
						clear
					fi
				fi
			done

			while true; do
				printf "\n\t\t\tNumero de días a transcurrir antes de desabilitar la cuenta: ";
				read inactive;
				if [ -z "$inactive" ]; then
					break;
				else
					if [[ $inactive =~ ^[0-9]*$ ]]; then
						break;
					else
						clear
						error "Ingrese datos numéricos\n";
						enter
						clear
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
						clear
						error "Ya existe un grupo con ese nombre\n";
						enter
						clear
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
					clear
					error "El GID debe ser mayor a 1000 y menor a 1100\n";
					enter
					clear;
				else
					validar=$(awk -F: -v auxgid="$gid" '{ if ($3 == auxgid) v = "si" }END{ print v }' /etc/group);
					if [ -n "$validar" ]; then
						clear
						error "Ya existe un grupo con ese GID\n";
						enter
						clear
					else
						break;
					fi
				fi
			done;

			printf "\n\n\t\t\t--- En /etc/passwd\n";
			#echo "$username:x:$uid:$gid:$comentario:$dir:$shell" >> /etc/passwd;
            printf "\t\t\t$username:x:$uid:$gid:$comentario:$dir:$shell\n";

			printf "\n\t\t\t--- En /etc/group\n";
			#echo "$namegroup:x:$gid:$username" >> /etc/group;
			printf "\t\t\t$namegroup:x:$gid:$username\n";

			if [ -z "$passwd" ]; then
				hashed_passwd="*";
			else
				hashed_passwd=$(echo -n "$passwd" | sha256sum | awk '{print $1}');
			fi
			printf "\n\t\t\t--- En /etc/shadow\n";
			aux=$((max - fecha_ac))
			res=$(((aux / (24 * 60 * 60) + 1)))
			echo "$username:$hashed_passwd:$lastchg:$min:$res:$warm:$inactive::" >> /home/cipher/Documentos/prueba.txt;
			printf "\t\t\t$username:$hashed_passwd:$lastchg:$min:$res:$warm:$inactive::\n\n";
			break;
		fi
	done
else
        error "No tienes permisos para crear un nuevo usuario\n";
fi