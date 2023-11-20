#/bin/bash

usuario=$(whoami)
uid=1015
gid=1015
if [ "$usuario" = "root" ]; then
	echo "Eres root vamos a crear un nuevo usuario"
	read -p "Ingrese nombre completo del usuario:  " nomUsua
	read -p "Ingrese el nombre de usuario:  " username
	read -p "Ingrese la cotraseña:  "  password
	read -p "Nombre del grupo:  " nomGrup
	home_directory="/home/$username"

	if [ -d "/home/$username" ]; then
		echo "El usuario $username ya existe."
	else
		echo "--- En el archivo  /etc/passwd"
		echo "$username:x:$uid:$gid:$nomUsua:$home_directory:/bin/bash"
		echo "--- En el archivo  /etc/shadow"
		echo "$username:$password:salto:ultimocambio:dias_vigecia:expiracion:warning:inactividad:expiracion_desactivada:reservado"
		echo "--- En el archivo  /etc/group"
		echo "$nomGrup:x:$gid:usuarios"
	fi
else
	echo "No tienes los suficietes permisos para crear usuarios."
fi
