#!/usr/bin/env bash
# Читает из stdin строку и преобразует ее ASCII->HEX
# Если строка начинается с 0x, то делает обратное преобразование (между чисел могут быть пробелы)
set -euo pipefail

IFS= read -r line || exit 0

if [[ "$line" == 0x* ]]; then
  hex="${line#0x}"
  hex="$(printf '%s' "$hex" | tr -d '[:space:]')"

  if (( ${#hex} % 2 != 0 )); then
    echo "Ошибка: hex-строка должна содержать чётное число символов" >&2
    exit 1
  fi

  printf '%s' "$hex" | xxd -r -p
  echo
else
  printf '%s' "$line" | xxd -p
fi
