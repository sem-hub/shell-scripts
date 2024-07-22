#!/bin/bash

source ~/bin/hosts-init.sh

if [ -z "$1" -o -z "$2" ]; then
	echo "Using: $0 <file> <host>:<remote_path>"
	echo "Or: $0 <host>:<remote_path> <local_path>"
	exit 1
fi

in=false
if [[ $1 =~ ":" ]]; then
	IFS=':'; arr=($1); unset IFS;
	host=${arr[0]}
	in=true
fi
out=false
if [[ $2 =~ ":" ]]; then
	IFS=':'; arr=($2); unset IFS;
	host=${arr[0]}
	file=$1
	out=true
fi

if [ $in = false ] && [ $out = false ]; then
	echo Neither in nor out
	exit 1
fi

if [ $out = true ] && [ ! -f "$file" ]; then
	echo "Can't find file: $file"
	exit 1
fi

found=false
for h in $HOSTS; do
	if [ $host = $h ]; then
		found=true
	fi
done

if [ ! $found ]; then
	echo "$host is unknown for me"
	exit 1
fi

knock_host $host
echo scp $*
env scp $*
