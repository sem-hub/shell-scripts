#!/bin/bash

# apt install hjson-go

for uri in `hjson-cli -c | jq -r '.Peers[]'`; do
	x=${uri#*://}
	u=`echo ${x%:*} | tr -d '[]'`
	echo fping -c 10 -q -m -A $u
	fping -c 10 -q -m -A $u
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo "====> Peer $u is dead"
	fi
done
