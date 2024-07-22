#!/bin/bash

source ~/bin/hosts-init.sh

if [ $# -lt 1 ]; then
	/usr/bin/ssh
	exit $?
fi
host=$1
shift

if [ $host = "-4" ]; then
	echo "IPv4"
	ipv4="-4"
	host=$1
	shift
fi
found=false
for h in $HOSTS; do
	if [ $host = $h ]; then
		found=true
	fi
done

if $found; then
	knock_host $host $ipv4
	echo "ssh $ipv4 $host $*"
	echo -ne "\033]30;ssh $host\007"
	/usr/bin/env ssh $ipv4 $host $*
else
	echo "ssh $ipv4 $host $*"
	echo -ne "\033]30;ssh $host\007"
	/usr/bin/env ssh $ipv4 $host $*
fi
echo -ne "\033]30;%d:%n\007"
