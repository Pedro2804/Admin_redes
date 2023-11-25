
function main(){
	for ((i=0; i<40; i++)); do
		for ((j=0; j<170; j++)); do
			if [ $i -lt 8 ] || [ $i -gt 27 ] ; then
				label $i $j "*";
			elif [ $j -lt 35 ] || [ $j -gt 134 ] ; then
				label $i $j "*";
			fi
		done
	done

	label 8 35 "____________________________________________________________________________________________________";
	label 10 $1 "$2";

	for ((i=9; i<=26; i++)); do
		label $i 35 "|";
		label $i 134 "|";
	done

	label 27 35 "____________________________________________________________________________________________________";
}

function move_cursor() {
    tput cup $1 $2; #row, col
}

function label() {
	printf "\e[%s;%sH%s" "$1" "$2" "$3"; #row, col, message
}

function enter() {
    label $1 75  "ENTER para continuar...";
	read
}

function error() {
	local message=$2;
	clear
    main $4 "$3";
    label 17 $1 "ERROR!... $message";
	enter 24
	clear
	main $4 "$3";
}

function abortar() {
	clear
	exit 1;
}

function finish(){
	for ((i=0; i<40; i++)); do
		for ((j=0; j<170; j++)); do
			if [ $i -lt 15 ] || [ $i -gt 27 ] ; then
				label $i $j "!";
			elif [ $j -lt 55 ] || [ $j -gt 114 ] ; then
				label $i $j "!";
			fi
		done
	done

	label 20 68 "-----USUARIO CREADO EXITOSAMENTE-----";
	enter 25;
	clear;
}