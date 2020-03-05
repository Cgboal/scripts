#!/usr/bin/env bash


# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
__TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`

arg1="${1:-}"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT


init() {
    if [ ! -d $HOME/.recon/ ]; then
        mkdir $HOME/.recon/
    fi

    mkdir -p $HOME/.recon/current/
    mkdir -p $HOME/.recon/previous/
    mkdir -p $HOME/.recon/archive/
    mkdir -p $HOME/.recon/archive/subdomains/

    if [ -d $HOME/.recon/platform-targets ]; then
        cd $HOME/.recon/platform-targets;
        git pull;
    else
        git clone https://github.com/arkadiyt/bounty-targets-data $HOME/.recon/platform-targets;
    fi

    cp -rf $HOME/.recon/current $HOME/.recon/previous

}

parse_h1() {
    cd $HOME/.recon/platform-targets/data/
    h1_targets=$(cat hackerone_data.json | jq '.[].targets.in_scope[] | select(.asset_type=="URL").asset_identifier' | sed s/\"//g)
    echo $h1_targets | tr ' ' '\n' | grep "^*." | grep -v "*$" | sed s/*.//g > $HOME/.recon/current/h1_wildcards.txt
    cat $HOME/.recon/current/h1_wildcards.txt >> $HOME/.recon/current/wildcards.txt
}

parse_bugcrowd() {
    cd $HOME/.recon/platform-targets/data/
    bugcrowd_targets=$(cat bugcrowd_data.json |jq '.[].targets.in_scope[] | select(.type=="website").target' | sed s/\"//g)
    echo $bugcrowd_targets | tr ' ' '\n' | grep "^*." | grep -v "*$" | sed s/*.//g > $HOME/.recon/current/bugcrowd_wildcards.txt
    cat $HOME/.recon/current/bugcrowd_wildcards.txt >> $HOME/.recon/current/wildcards.txt
}


enum_wildcards() {
    cd $HOME/.recon/current/
    mkdir -p subfinder
    mkdir -p amass

    echo "[+] Running Subfinder"
    cat wildcards.txt | parallel --jobs 10 "subfinder -d {} -o ./subfinder/{}.txt" &

    echo "[+] Running Amass"
    cat wildcards.txt | parallel --jobs 10 "amass enum -d {} -o ./amass/{}.txt" &

    while [[ $(jobs | wc -l) -ge $1 ]]; do
        sleep 1
    done

    cat ./subfinder/* > subdomains.txt
    cat ./amass/* >> subdomains.txt
}

resolve_dns() {
    cd $HOME/.recon/current/

    echo "[+] Resolving Subdomains"
    cat ./subfinder/*.txt ./amass/*.txt | zdns -verbosity 1 > dns_records.txt
}


main() {
    init
    parse_h1
    parse_bugcrowd
    enum_wildcards
    resolve_dns
}

main
