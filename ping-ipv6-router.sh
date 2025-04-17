#!/bin/bash

interface=$(ip route | awk '/default/ {print $5}')
prefix=$(ip -6 route show dev $interface | grep "proto ra metric 1" | grep -v ^default | awk '{print $1}')
gw=$(echo $prefix|sed 's#/.*$##')
echo ping $gw
ping -c 1 $gw > /dev/null
