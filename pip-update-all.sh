#!/bin/bash

#PIP_CMD=sudo pip3
PIP_CMD=pip3

$PIP_CMD list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 $PIP_CMD install -U
