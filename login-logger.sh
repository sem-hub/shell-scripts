#!/bin/bash

# Put it in /usr/local/bin
# Add this line into the beggining of /etc/pam.d/sshd:
# session required pam_exec.so /usr/local/bin/login-logger.sh

LOG_FILE="/var/log/ssh-auth"
BOT_ID="bot123456:*****"
CHAT_ID="12345678"

HOST=`hostname -f`
DATE_ISO=`date --iso-8601="seconds"`
DATE_TIME=`date "+%F %T"`
LOG_ENTRY="[${DATE_TIME}] ${HOST}: ${PAM_TYPE}: ${PAM_USER} from ${PAM_RHOST}"

if [ ! -f ${LOG_FILE} ]; then
	touch ${LOG_FILE}
	chown root:adm ${LOG_FILE}
	chmod 0640 ${LOG_FILE}
fi

echo ${LOG_ENTRY} >> ${LOG_FILE}

curl -s -X POST https://api.telegram.org/$BOT_ID/sendMessage -d chat_id=$CHAT_ID -d text="$LOG_ENTRY"

exit 0
