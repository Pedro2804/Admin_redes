
function main(){
	label 2 35 "____________________________________________________________________________________________________";
	label 4 $1 "$2";

	for ((i=3; i<=20; i++)); do
		label $i 35 "|";
		label $i 134 "|";
	done

	label 21 35 "____________________________________________________________________________________________________";
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
    label 11 $1 "ERROR!... $message";
	enter 18
	clear
}