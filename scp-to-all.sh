#!/bin/bash

source ~/bin/hosts-init.sh

if [ -z "$1" -o -z "$2" ]; then
	echo "Using: $0 <file> <remote_path>"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "Can't find file: $1"
	exit 1
fi

for host in $HOSTS; do
	knock_host $host
	echo scp "$1" "$host:$2"
	env scp "$1" "$host:$2"
done
