#!/bin/bash

checkDec() {
	if ! [[ $1 =~ ^[0-9]+$ ]]; then
		echo "error: Not a decimal"; exit 1
	fi
}

checkBin() {
	if ! [[ $1 =~ ^[01]+$ ]]; then
		echo "error: Not a binary"; exit 1
	fi
}

checkHex() {
	if ! [[ $1 =~ ^[0-9a-f]+$ ]]; then
		echo "error: Not a hexadecimal"; exit 1
	fi
}

DecToBin() {
	local n bits sign=''
	(($1<0)) && sign=-
	for (( n=$sign$1 ; n>0 ; n >>= 1 )); do bits=$((n&1))$bits; done
	printf "%s\n" "$sign${bits-0}"
}

HexToDec() {
	echo "$((16#$1))"
}

BinToDec() {
	echo "$((2#$1))"
}

DecToHex() {
	printf "0x%x\n" $1
}

if [ $# -lt 2 ]; then
	echo -e "Using:\nconvert.sh -d|-h|-b 0xhex|dec|0bin"
	exit 0
fi

if [ $1 != "-d" -a $1 != "-h" -a $1 != "-b" ]; then
	echo "Unknown flag: $1"
	exit 1
fi

interim=$2
if [[ $2 == 0x* ]]; then
	checkHex ${2#0x}
	interim=$(HexToDec ${2#0x})
elif [[ $2 == 0* ]]; then
	checkBin $2
	interim=$(BinToDec $2)
else
	checkDec $2
fi

if [ $1 == "-d" ]; then
	echo $interim
elif [ $1 == "-h" ]; then
	DecToHex $interim
else
	DecToBin $interim
fi
