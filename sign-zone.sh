#!/bin/sh

curdir=`dirname $0`
cd $curdir

echo Generating TLSA records...
/usr/local/bin/generate_tlsa.py generate_tlsa.txt > semmy.ru-tlsa.inc

echo Checking zone file syntax...
/usr/bin/named-checkzone semmy.ru semmy.ru > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "**** Zone semmy.ru has a syntax error. Fix it first."
	exit 1
fi

curr_soa=`awk '/\t*(\d*)\t*; serial \(YYYYMMDDNN\)/ {print $1}' semmy.ru`
curr_date=`date +'%Y%m%d00'`

if [ "$curr_soa" -eq "$curr_date" ]; then
        curr_date=$((curr_date+1))
fi
sed -i 's#[[:space:]]*[[:digit:]]*[[:space:]]*; serial (YYYYMMDDNN)#\t\t'$curr_date'\t; serial (YYYYMMDDNN)#' semmy.ru

/usr/bin/dnssec-signzone -S -N keep semmy.ru
echo "Zone semmy.ru signed"

/usr/sbin/rndc reload 2> /dev/null
exit 0
