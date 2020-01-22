dehashed_query() {
	http -a $DEHASHED_USERNAME:$DEHASHED_API_KEY https://api.dehashed.com/search\?query\=$1 "Accept: application/json" 
}

dehashed_colon_from_json() {
	jq -r '.entries[] | select(.password | length >= 1) | [.email, .password]| @csv' | sed s/\"//g | sed s/,/:/g
}
