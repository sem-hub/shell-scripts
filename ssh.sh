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
	#echo "ssh $options $host $cmd"
	#echo -ne "\033]30;ssh $host\007"
	/usr/bin/env ssh $options $host $cmd
else
	#echo "ssh $ipv4 $host $*"
	#echo -ne "\033]30;ssh $host\007"
	/usr/bin/env ssh $options $host $cmd
fi
#echo -ne "\033]30;%d:%n\007"
