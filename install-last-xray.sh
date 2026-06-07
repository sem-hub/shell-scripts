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

install_startup_service_file() {
  cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -confdir /usr/local/etc/xray
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
}

install_configs() {
  cat > ${CONF_DIR}/00_log.json << EOF
{   
  "log": {
    "loglevel": "warnings"
  }
}
EOF
  cat > ${CONF_DIR}/20_dns.json << EOF
{
  "dns": {
    "servers": [
      {
        "address": "tls://9.9.9.9"
      },
      "localhost"
    ]
  },
  "tag": "dns_inbound"
}
EOF
  cat > ${CONF_DIR}/30_routing.json << EOF
{
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "protocol": "bittorent",
        "outboundTag": "block"
      },
      {
        "port": 853,
        "outboundTag": "direct"
      },
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "direct",
        "type": "field"
      },
      {
        "ip": [
          "geoip:ru"
        ],
        "outboundTag": "block",
        "type": "field"
      },
      {
        "domain": [
          "geosite:category-ru"
        ],
        "outboundTag": "block",
        "type": "field"
      },
      {
        "inboundTag": [ "vless-in", "socks-in" ],
        "outboundTag": "direct"
      }
    ]
  }
}
EOF
  cat > ${CONF_DIR}/50_inbound_socks.json << EOF
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "udp": true
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      },
      "tag": "socks-in"
    }
  ]
}
EOF
  cat > ${CONF_DIR}/60_outbound.json << EOF
{
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ]
}
EOF
  xray x25519 > ${CONF_DIR}/vless.keys
  USER_ID=$(xray uuid)
  PRIV_KEY=$(grep PrivateKey: ${CONF_DIR}/vless.keys|sed -e 's/PrivateKey: //')
  SHORT_ID=$(openssl rand -hex 4)
  cat > ${CONF_DIR}/55_inbound_vless.json << EOF
{   
  "inbounds": [
    {   
      "port": 5443,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "tag": "vless-in",
      "settings": {
        "clients": [
          {   
            "id": "${USER_ID}",
            "level": 0,
            "flow": "xtls-rprx-vision" ,
            "email": "sem@semmy.ru"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "raw",
        "rawSetting": {
          "acceptProxyProtocol": true
        },
        "security": "reality",
        "realitySettings": {
          "show": false,                // if true, show debug info
          "dest": "cedro.agency:443",
          "serverNames": [
            "cedro.agency"
          ],
          "fingerprint": "chrome",
          "privateKey": "${PRIV_KEY}",
          "shortIds": [
            "${SHORT_ID}"
          ]
        },
        "sockopt": {
          "acceptProxyProtocol": true,
          "tcpMptcp": true,
          "tcpFastOpen": true,
          "tcpNoDelay": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ],
        "routeOnly": true
      }
    }
  ]
}
EOF
}
DAT_PATH=/usr/local/bin
get_latest_stable_version
identify_the_operating_system_and_architecture
TMP_DIRECTORY="$(mktemp -d)"
download_xray
decompression ${ZIP_FILE}
systemctl stop xray
echo Install Xray
install_xray
echo Insall Geo data
install_geodata
echo Install systemd service file
install_startup_service_file
CONF_DIR=/usr/local/etc/xray
mkdir ${CONF_DIR}
echo Install configs
install_configs
echo Start Xray
systemctl start xray
echo Remove ${TMP_DIRECTORY}
rm -r "${TMP_DIRECTORY}"
systemctl status xray|cat
echo UUID: $USER_ID
echo Reality values:
grep PublicKey ${CONF_DIR}/vless.keys
echo ShortID: $SHORT_ID
