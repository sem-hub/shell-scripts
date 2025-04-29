#!/bin/sh
ip -4 addr show dev wlan0 primary | awk '/inet/ {print $2}' | sed -e 's#/.*$##'
