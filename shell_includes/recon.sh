zdns_ip_list() {
        jq -r '.data.answers[].answer'
}

top_ports() {
    nmap -oG - -v --top-ports $1 | awk -F'[);]' '/Ports/{print $2}' 2>/dev/null
}

bottom_ports() {
    nmap -oG - -v --top-ports $(expr 65535 - $1) | awk -F'[);]' '/Ports/{print $2}' 2>/dev/null
}

