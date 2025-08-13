#!/bin/bash

CERT=$(ssh-keygen -L -f /etc/ssh/ssh_host_ed25519_key-cert.pub | grep "Public key" |sed -e 's/.*ED25519-CERT //')
KEY=$(sudo ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key | sed -e 's/256 //' | awk '{print $1}')
PUBKEY=$(sudo ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub | sed -e 's/256 //' | awk '{print $1}')

if [ $CERT == $KEY -a $KEY == $PUBKEY ]; then
	echo OK
else
	echo "key:   $KEY"
	echo "pubkey:$PUBKEY"
	echo "cert:  $CERT"
fi
