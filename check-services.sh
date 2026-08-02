#!/bin/bash

check_service() {
	service=$1
	service_run=$(ps xa | grep -E "(^|[^[:alnum:]_-])$service([^[:alnum:]_-]|$)"|grep -v grep)
	if [ -z "$service_run" ]; then
		echo ERR: $service is down
		exit 1
	fi
}
check_service "nginx"
check_service "xray"
