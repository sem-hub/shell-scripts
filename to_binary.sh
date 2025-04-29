#!/bin/bash

toBinary(){
    local n bits sign=''
    (($1<0)) && sign=-
    for (( n=$sign$1 ; n>0 ; n >>= 1 )); do bits=$((n&1))$bits; done
    printf "%s\n" "$sign${bits-0}"
}

if ! [[ $1 =~ ^[0-9]+$ ]] ; then
   echo "error: Not a number" >&2; exit 1
fi

toBinary $1
