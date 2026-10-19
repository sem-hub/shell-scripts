#!/bin/bash

source ~/bin/hosts-init.sh

if [ -z "$1" -o -z "$2" ]; then
	echo "Using: $0 <files> <remote_path>"
	exit 1
fi

for f in $*; do
	if [ ${#*} == 1 ]; then
		target=$f
	else
		if [ ! -f "$f" ]; then
			echo "Can't find file: $1"
			exit 1
		fi
		files+="$f "
	fi
	shift
done

for host in $HOSTS; do
	knock_host $host
	echo scp "$files" "$host:$target"
	env scp $files "$host:$target"
done
