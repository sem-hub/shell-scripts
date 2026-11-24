#!/bin/bash

CHECK_SERVICES="nginx xray"

check_service() {
	service=$1
	#echo "Checking service $service"
	service_run=$(ps xa | grep -E "(^|[^[:alnum:]_-])$service([^[:alnum:]_-]|$)"|grep -v grep)
	if [ -z "$service_run" ]; then
		echo ERR: $service is down
		return 1
	fi
	return 0
}

for service in $CHECK_SERVICES; do
	check_service $service
	if [ $? -ne 0 ]; then
		echo restart
		sudo systemctl restart $service
	fi
done
