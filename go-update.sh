#!/bin/bash

if [ ! -d /usr/local/go ]; then
	echo "golang is not installed"
	exit 1
fi

release=$(curl --silent https://go.dev/doc/devel/release | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1)

installed=($(/usr/local/go/bin/go version))
arch=$(echo ${installed[3]}|sed 's#/#-#')

if [ ${release} != ${installed[2]} ]; then
	echo -n "go version installed: ${installed[2]}, a new version available: $release. Process? "
	read
	if [ $REPLY == "yes" -o $REPLY == "y" ]; then 
		curl --output-dir /tmp -OL https://go.dev/dl/${release}.${arch}.tar.gz
		sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/${release}.${arch}.tar.gz
		rm /tmp/${release}.${arch}.tar.gz
	fi
else
	echo "golang is up to date"
fi

/usr/local/go/bin/go version
