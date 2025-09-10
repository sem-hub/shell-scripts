#!/bin/bash

if [ -f /var/run/reboot-required ]; then
	echo Need reboot
fi
