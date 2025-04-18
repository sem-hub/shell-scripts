#!/bin/bash

# apt install curl fping

# defaults
PING_COUNT=5
RESULT_NUMBER=0
DEBUG=0
PROTOCOL="tls://"
SCRIPT_READY=0
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--count) PING_COUNT="$2"; shift ;;
        -n|--num) RESULT_NUMBER="$2"; shift ;;
        -d|--debug) DEBUG=1 ;;
	-s|--script) SCRIPT_READY=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

result=""
hosts=()
content=$(curl -sSf https://raw.githubusercontent.com/yggdrasil-network/public-peers/refs/heads/master/europe/russia.md)
for h in $(echo "$content"|awk '/(tcp|tls|quic|ws):\/\/([-a-zA-Z0-9\.:\[\]]+):[0-9]+/ {print gensub(/\s+\* `(tcp|tls|quic|ws):\/\/\[?([-a-zA-Z0-9\.:]+)\]?:[0-9]+.*`.*$/, "\\2", 1)}' | sort -u); do
	hosts+=($h)
done
echo Found ${#hosts[@]} public peers

i=0
for host in ${hosts[@]}; do
	i=$((i+1))
	if [ $DEBUG -eq 1 ]; then
		echo $i: ping $host
	fi
	out=$(fping -c $PING_COUNT -q -m -A $host 2>&1|grep -v duplicate)
	retVal=$?
	if [ $retVal -ne 0 ]; then
		if [ $DEBUG -eq 1 ]; then
			echo "====> Peer $host is dead"
		else
			echo -n x
		fi
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
			if [ $DEBUG -eq 1 ]; then
				echo "$ip : rtt $avgrtt"
			else
				echo -n .
			fi
			result="${result}$host ($ip) $avgrtt
"
		else
			if [ $loss -eq 100 ]; then
				if [ $DEBUG -eq 1 ]; then
					echo "===> $ip is unreachable."
				else
					echo -n u
				fi
			else
				if [ $DEBUG -eq 1 ]; then
					echo "===> $ip has $loss% lost packets. Remove it."
				else
					echo -n b
				fi
			fi
		fi
	done
	if [ $(($i%5)) -eq 0 ]; then
		echo -n $i
	fi
done

echo

if [ $DEBUG -eq 1 ]; then
	echo "================== SORTED RESULTS =================="
fi

sorted=$(echo "$result"|grep -v '^$'|sort -n -k3)
if [ $SCRIPT_READY -eq 0 ]; then
	if [ $RESULT_NUMBER -eq 0 ]; then
		echo "${sorted}"
	else
		echo "${sorted}"|head -n $RESULT_NUMBER
	fi
else
	peers=()
	for f in "${sorted}"; do
		p=$(echo "$f"|grep -v '^$'|awk '{ print $1 }')
		found=0
		for i in "${!peers[@]}"; do
			if [ "$p" == "${peers[$i]}" ]; then
				found=1
			fi
		done
		if [ $found -eq 0 ]; then
			peers+=($p)
		fi
	done
	i=0
	for e in "${peers[@]}"; do
		if [ $RESULT_NUMBER -eq 0 -o $i -lt $RESULT_NUMBER ]; then
			p=$(echo "$content"|grep "${PROTOCOL}${e}"|sed -e 's/^[^`]*`//;s/`.*$//')
			if [ "$p" != "" ]; then
				echo $p
				i=$((i+1))
			fi
		fi
	done
fi
