#!/bin/bash

# apt install curl fping

result=""
hosts=()
for h in $(curl -sSf https://raw.githubusercontent.com/yggdrasil-network/public-peers/refs/heads/master/europe/russia.md|awk '/(tcp|tls|quic|ws):\/\/([-a-zA-Z0-9\.:\[\]]+):[0-9]+/ {print gensub(/\s+\* `(tcp|tls|quic|ws):\/\/\[?([-a-zA-Z0-9\.:]+)\]?:[0-9]+.*`.*$/, "\\2", 1)}' | sort -u); do
	hosts+=($h)
done
echo Found ${#hosts[@]} public peers

i=0
for host in ${hosts[@]}; do
	i=$((i+1))
	echo $i: ping $host
	out=$(fping -c 5 -q -m -A $host 2>&1|grep -v duplicate)
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "====> Peer $host is dead"
		continue
	fi
	IFS=$'\n'
	#out=($out)
	for o in $out; do
		#echo $o
		ip=$(echo "$o"| awk '{print $1}')
		loss=$(echo "$o"| awk '{print gensub(/^.*[0-9]+\/[0-9]+\/([0-9]+)%.*$/, "\\1", 1)}')
		avgrtt=$(echo "$o"| awk '{print gensub(/^.*[0-9.]+\/([0-9.]+)\/[0-9.]+.*$/, "\\1", 1, $8)}')
		if [ $loss -eq 0 ]; then
			echo "$ip : rtt $avgrtt"
			result="${result}$host ($ip) $avgrtt
"
		else
			if [ $loss -eq 100 ]; then
				echo "===> $ip is unreachable."
			else
				echo "===> $ip has $loss% lost packets. Remove it."
			fi
		fi
	done
done

echo
echo "================== SORTED RESULTS =================="
echo "$result"|sort -n -k3
