#!/bin/bash
 
INSYNC=`timeout 30 /root/.local/share/solana/install/active_release/bin/solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899 | grep caught`

if [[ -z ${INSYNC} ]]
then
 echo "`date` ALARM! node is out of sync"
  "/root/Send_msg_toTelBot.sh" "$HOSTNAME inform you:" "ALARM! Solana node is out of sync!"  2>&1 > /dev/null
else
 echo "`date` node is synced"
fi
