#!/bin/bash

wget -q -O- https://launchpad.net/ubuntu/+archivemirrors | grep -Po 'http[s]?://[^"]*/(ubuntu|ubuntu-archive)/' | grep -v 'launchpad\|ubuntu.com\|Bugs' | sed -e 's/\x1b\[[0-9;]*m\x1b\[K//g' |sort -u > mirrors.txt
