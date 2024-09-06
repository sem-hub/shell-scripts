#!/bin/bash

met_flag=false
options=""
need_ip4=false
while [[ "$#" -gt 0 ]]; do
	if [[ $1 == -4 ]]; then
		need_ip4=true
		options="$options $1"
		shift
	fi
	if [[ $1 == -* ]]; then
		options="$options $1"
		shift
		meet_flag=true
	elif [[ "$meet_flag" = true ]]; then
		options="$options $1"
		shift
		meet_flag=false
	else
		host=$1
		shift
		break
	fi
done
cmd=""
while [[ "$#" -gt 0 ]]; do
	cmd="$cmd $1"
	shift
done
