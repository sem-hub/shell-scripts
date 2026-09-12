#!/bin/bash

check_service() {
	service=$1
	service_run=$(ps xa | grep -E "(^|[^[:alnum:]_-])$service([^[:alnum:]_-]|$)"|grep -v grep)
	if [ -z "$service_run" ]; then
		echo ERR: $service is down
		return 1
	fi
	return 0
}
check_service "nginx"
if [ $? -ne 0 ]; then
	echo restart
	sudo systemctl restart nginx
fi
check_service "xray"
if [ $? -ne 0 ]; then
	echo restart
	sudo systemctl restart xray
fi
