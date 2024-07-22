#!/bin/bash

source ~/bin/hosts-init.sh

if [ -z "$1" ]; then
	echo "Using: $0 <command>"
	exit 1
fi

for host in $HOSTS; do
	echo "Connecting to $host..."
	ssh.sh $host $*
	echo "================================="
done
