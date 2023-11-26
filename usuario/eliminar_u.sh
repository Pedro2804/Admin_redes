#!/bin/bash
source interfaz.sh;

trap 'abortar' INT TSTP
clear

if [ $(whoami) = root ]; then

    main 76 "ELIMINAR USUARIO";
    while true; do
        label 12 63 "> Ingresa el nombre de usuario a eliminar:";
        move_cursor 11 105;
        read username;

        dir=$(find /home -type d -name "$username");
        if [ -n "$dir" ]; then
            rm -r /home/$username;

            linea_passwd=$(awk -F: -v usuario="$username" '$1 == usuario' /etc/passwd);
            sed -i "/$linea_passwd/d" /etc/passwd

            linea_shadow=$(awk -F: -v usuario="$username" '$1 == usuario' /etc/shadow);
            sed -i "/$linea_shadow/d" /etc/shadow
            
            finish 72 "-----USUARIO ELIMINADO-----";
            main 76 "ELIMINAR USUARIO";
            label 12 63 "> Ingresa el nombre de usuario a eliminar: $username";
            while true; do
                label 14 63 "> ¿Eliminar el grupo? [Y/n]:";
                move_cursor 13 91;
                read op;

                if [[ $op =~ ^[Yyn]$ ]]; then
                    if [ $op == "n" ]; then
                        clear
                        exit 0;
                    else
                        clear
                        main 77 "ELIMINAR GRUPO";
                        while true; do
                            label 12 63 "> Ingresa el nombre del grupo a eliminar:";
                            move_cursor 11 104;
                            read group;

                            if [ -z  "$group" ]; then
                                error 66 "Ingrese un nombre de grupo" "ELIMINAR GRUPO" 77;
                            elif ! [[ $group =~ ^[a-z0-9_]{1,32}$ ]]; then
                                error 55 "Ingrese datos alfanuméricos y minúsculas sin espacio" "ELIMINAR GRUPO" 77;
                            else
                                linea_group=$(awk -F: -v grupo="$group" '$1 == grupo' /etc/group);
                                
                                if [ -n "$linea_group" ]; then
                                    sed -i "/$linea_passwd/d" /etc/passwd
                                    finish 73 "-----GRUPO ELIMINADO-----";
                                    exit 0;
                                else
                                    error 67 "El grupo ingresado no existe" "ELIMINAR GRUPO" 77;
                                fi
                            fi
                        done
                    fi
                else
                    error 65 "Ingrese una opción válida" "ELIMINAR USUARIO" 76;
                fi
                label 12 63 "> Ingresa el nombre de usuario a eliminar: $username";
            done

        elif [ -z  "$username" ]; then
			error 66 "Ingrese un nombre de usuario" "ELIMINAR USUARIO" 76;
		elif ! [[ $username =~ ^[a-z0-9_]{1,32}$ ]]; then
			error 55 "Ingrese datos alfanuméricos y minúsculas sin espacio" "ELIMINAR USUARIO" 76;
        else
            error 67 "El usuario ingresado no existe" "ELIMINAR USUARIO" 76;
        fi
    done
else
        printf "No tienes permisos para eliminar un usuario\n";
fi

exit 0;