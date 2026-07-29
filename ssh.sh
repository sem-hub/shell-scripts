#!/bin/bash

source ~/bin/hosts-init.sh

if [ $# -lt 1 ]; then
	/usr/bin/ssh
	exit $?
fi

source ~/bin/parse-arguments.sh

if [ $need_ip4 = true ]; then
	echo "IPv4"
	ipv4="-4"
fi
found=false
for h in $HOSTS; do
	if [ "$host" = "$h" ]; then
		found=true
	fi
done

if $found; then
	knock_host $host $ipv4
fi

if [ -n "$SSH_USER" ]; then
	host="${SSH_USER}@$host"
fi
#echo "ssh $options $host $cmd"
#echo -ne "\033]30;ssh $host\007"
if [ -n "$cmd" ]; then
	/usr/bin/env ssh $options $host bash -c \"$cmd\"
else
	/usr/bin/env ssh $options $host
fi

#echo -ne "\033]30;%d:%n\007"
