#!/bin/bash

sudo mkdir -p /usr/local/apt-keys
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export BC1BF63BD10B8F1A | sudo tee /usr/local/apt-keys/yggdrasil-keyring.gpg > /dev/null

echo 'deb [signed-by=/usr/local/apt-keys/yggdrasil-keyring.gpg] http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' | sudo tee /etc/apt/sources.list.d/yggdrasil.list
sudo apt-get update

sudo apt-get install yggdrasil

yggdrasil -genconf | tee /etc/yggdrasil/yggdrasil.conf
sudo sed -i.orig -e 's#Peers: \[\]#Peers: [\n    tls://x-mow-1.sergeysedoy97.ru:65534\n  ]#' /etc/yggdrasil/yggdrasil.conf

sudo systemctl enable --now yggdrasil
