#!/bin/bash

HOSTS=$(cat ~/data/hosts.list)

function knock_host {
	echo knocking to $1 $2
	ipv4=$2
	knock_seq=$((cat ~/data/knocking/$1.knock) 2> /dev/null)
	if [ $? != 0 ]; then
		echo "error: can't find knocking squence for $1"
		return 1
	else
		env knock $ipv4 -d 100 $1 $knock_seq
	fi
}

