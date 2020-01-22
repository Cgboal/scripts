# Pulls out a list of affected assets from nessus csv files
nessus_find_assets() {
	if [[ -z $1 ]];
	then
		echo "Usage: cat nessus.csv | nessus_find_assets <issue name regex>"
		return
	fi	
	stdin=$(cat)

	ip_column=$(echo $stdin | find_csv_column_index "Host")
	port_column=$(echo $stdin | find_csv_column_index "Port")
	
	finding=$1
	data=$(echo $stdin | grep -i $1)

	for port in $(echo $data | sort -t, -k$port_column,$port_column -u | cut -d, -f $port_column | sed s/\"//g); do 
		echo "---- $port ----"
		echo $data | sed s/\"//g | awk -sF, '$'$port_column' == '"$port"' {print $'$ip_column'}' | sort -u    
	done
}

