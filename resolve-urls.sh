#!/bin/bash

function get_hostname_from_url() {
	echo $1 | sed -e 's|^[^/]*//||' -e 's|/.*$||'
}

declare -a hosts
let i=0
while read url; do
	hosts+=( $(get_hostname_from_url $url) )
	let i++
done
echo $i

declare -A ips
let j=0
for host in ${hosts[@]}; do
	addrs=()
	for addr in $(dig +short $host | grep -v '\.$'); do
		addrs+=($addr)
	done
	for addr in $(dig +short $host AAAA | grep -v '\.$'); do
		addrs+=($addr)
	done

	let j++
	ips[$host]=${addrs[@]}
	if (( $(($j % 10)) == 0 )); then
		echo -n $j
	else
		echo -n .
	fi
done

echo

for host in ${!ips[@]}; do
	echo $host: ${ips[$host]}
done
