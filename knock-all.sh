#!/bin/bash

source ~/bin/hosts-init.sh

for h in $HOSTS; do
	knock_host $h
done
