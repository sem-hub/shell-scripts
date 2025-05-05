#!/bin/bash

# Адрес и порт WireGuard-сервера
ENDPOINT_IP="2a01:230:4:8e1::2"
ENDPOINT_PORT="63130"

# Отправить 5 случайных пакетов по UDP
for i in {1..5}; do
    head -c 100 /dev/urandom | nc -u -w1 "$ENDPOINT_IP" "$ENDPOINT_PORT"
    sleep 0.2
done

exit 0
