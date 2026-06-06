#!/bin/bash

get_latest_stable_version() {
  INSTALL_VERSION=$(curl -sL https://api.github.com/repos/XTLS/Xray-core/releases/latest | jq ".tag_name" | tr -d '"')
}

identify_the_operating_system_and_architecture() {
  if [[ "$(uname)" != 'Linux' ]]; then
    echo "error: This operating system is not supported."
    return 1
  fi
  case "$(uname -m)" in
  'i386' | 'i686')
    MACHINE='32'
    ;;
  'amd64' | 'x86_64')
    MACHINE='64'
    ;;
  'armv5tel')
    MACHINE='arm32-v5'
    ;;
  'armv6l')
    MACHINE='arm32-v6'
    grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
    ;;
  'armv7' | 'armv7l')
    MACHINE='arm32-v7a'
    grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
    ;;
  'armv8' | 'aarch64')
    MACHINE='arm64-v8a'
    ;;
  'mips')
    MACHINE='mips32'
    ;;
  'mipsle')
    MACHINE='mips32le'
    ;;
  'mips64')
    MACHINE='mips64'
    lscpu | grep -q "Little Endian" && MACHINE='mips64le'
    ;;
  'mips64le')
    MACHINE='mips64le'
    ;;
  'ppc64')
    MACHINE='ppc64'
    ;;
  'ppc64le')
    MACHINE='ppc64le'
    ;;
  'riscv64')
    MACHINE='riscv64'
    ;;
  's390x')
    MACHINE='s390x'
    ;;
  *)
    echo "error: The architecture is not supported."
    return 1
    ;;
  esac
}

download_xray() {
  local DOWNLOAD_LINK="https://github.com/XTLS/Xray-core/releases/download/${INSTALL_VERSION}/Xray-linux-${MACHINE}.zip"
  ZIP_FILE="${TMP_DIRECTORY}/Xray-linux-${MACHINE}.zip"
  echo "Downloading Xray archive: $DOWNLOAD_LINK"
  if curl -f -x "${PROXY}" -R -L -H 'Cache-Control: no-cache' -o "${ZIP_FILE}" "$DOWNLOAD_LINK"; then
    echo "ok."
  else
    echo 'error: Download failed! Please check your network or try again.'
    return 1
  fi
  echo "Downloading verification file for Xray archive: ${DOWNLOAD_LINK}.dgst"
  if curl -f -x "${PROXY}" -sSRL -H 'Cache-Control: no-cache' -o "${ZIP_FILE}.dgst" "${DOWNLOAD_LINK}.dgst"; then
    echo "ok."
  else
    echo 'error: Download failed! Please check your network or try again.'
    return 1
  fi
  if grep 'Not Found' "${ZIP_FILE}.dgst"; then
    echo 'error: This version does not support verification. Please replace with another version.'
    return 1
  fi

  # Verification of Xray archive
  CHECKSUM=$(awk -F '= ' '/256=/ {print $2}' "${ZIP_FILE}.dgst")
  LOCALSUM=$(sha256sum "$ZIP_FILE" | awk '{printf $1}')
  if [[ "$CHECKSUM" != "$LOCALSUM" ]]; then
    echo 'error: SHA256 check failed! Please check your network or try again.'
    return 1
  fi
}

decompression() {
  if ! unzip -q "$1" -d "$TMP_DIRECTORY"; then
    echo 'error: Xray decompression failed.'
    "rm" -r "$TMP_DIRECTORY"
    echo "removed: $TMP_DIRECTORY"
    exit 1
  fi
  echo "info: Extract the Xray package to $TMP_DIRECTORY and prepare it for installation."
}

install_xray() {
  install -m 755 "${TMP_DIRECTORY}/xray" "/usr/local/bin"
}

install_geodata() {
  download_geodata() {
    if ! curl -x "${PROXY}" -R -L -H 'Cache-Control: no-cache' -o "${dir_tmp}/${2}" "${1}"; then
      echo 'error: Download failed! Please check your network or try again.'
      exit 1
    fi
    if ! curl -x "${PROXY}" -R -L -H 'Cache-Control: no-cache' -o "${dir_tmp}/${2}.sha256sum" "${1}.sha256sum"; then
      echo 'error: Download failed! Please check your network or try again.'
      exit 1
    fi
  }
  local download_link_geoip="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
  local download_link_geosite="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
  local file_ip='geoip.dat'
  local file_dlc='geosite.dat'
  local file_site='geosite.dat'
  local dir_tmp
  dir_tmp="$(mktemp -d)"
  download_geodata $download_link_geoip $file_ip
  download_geodata $download_link_geosite $file_dlc
  cd "${dir_tmp}" || exit
  for i in "${dir_tmp}"/*.sha256sum; do
    if ! sha256sum -c "${i}"; then
      echo 'error: Check failed! Please check your network or try again.'
      exit 1
    fi
  done
  cd - >/dev/null || exit 1
  install -d "$DAT_PATH"
  install -m 644 "${dir_tmp}"/${file_dlc} "${DAT_PATH}"/${file_site}
  install -m 644 "${dir_tmp}"/${file_ip} "${DAT_PATH}"/${file_ip}
  rm -r "${dir_tmp}"
  return 0
}

DAT_PATH=/usr/local/bin
get_latest_stable_version
identify_the_operating_system_and_architecture
TMP_DIRECTORY="$(mktemp -d)"
download_xray
decompression ${ZIP_FILE}
systemctl stop xray
install_xray
install_geodata
systemctl start xray
rm -r "${TMP_DIRECTORY}"
