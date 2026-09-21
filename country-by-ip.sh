#!/bin/bash

curl -s http://ip-api.com/json/$1| jq '.country, .as'
