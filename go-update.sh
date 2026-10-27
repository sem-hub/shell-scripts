#!/bin/bash

release=$(curl --silent https://go.dev/doc/devel/release | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1)

installed=($(/usr/local/go/bin/go version 2> /dev/null))
arch=$(dpkg --print-architecture)

if [ -z ${installed} ]; then
	echo "go is not installed. Install it (release: $release)? "
elif [ ${release} != ${installed[2]} ]; then
	echo -n "go version installed: ${installed[2]}, a new version available: $release. Process? "
else
	echo "golang is up to date"
	exit 0
fi

read
if [ $REPLY == "yes" -o $REPLY == "y" ]; then 
	wget -P /tmp https://go.dev/dl/${release}.linux-${arch}.tar.gz
	if [ -d /usr/local/go ]; then
		sudo rm -rf /usr/local/go
	else
		sudo tar -C /usr/local -xzf /tmp/${release}.linux-${arch}.tar.gz
	fi
	rm /tmp/${release}.${arch}.tar.gz
fi

/usr/local/go/bin/go version
