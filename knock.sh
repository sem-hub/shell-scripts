#!/bin/bash

source ~/bin/hosts-init.sh


if [ -z "$1" ]; then
	echo "Using: $0 <host>"
	exit 1
fi

found=false
for host in $HOSTS; do
	if [ $host = $1 ]; then
		found=true
	fi
done

if ! $found; then
	echo "$1 is unknown for me"
	exit 1
fi

knock_host $1 $2
