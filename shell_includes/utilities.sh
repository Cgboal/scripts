#!/bin/bash


# Copying
alias "c=xclip" # copy to X clipboard (register *)
alias "cs=xclip -selection clipboard" # copy to system wide clipboard (register +)
alias "v=xclip -o" # output copied content (paste)
alias "vs=xclip -o -selection clipboard" # paste from system wide clipboard


find_csv_column_index() {
	read header
	echo $(echo $header | sed 's/,/\n/g' | grep -n '^'$1'$' | sed 's/:'$1'//g')
}

