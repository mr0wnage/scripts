#!/bin/bash
SCRIPT_DIR=/root/
APP_SOLANA=/root/.local/share/solana/install/active_release/bin/solana
APP_SOLANA_KEYGEN=/root/.local/share/solana/install/active_release/bin/solana-keygen
KEYS_PATH=/root/solana/validator-keypair.json
ID_PUBKEY=`${APP_SOLANA_KEYGEN} pubkey ${KEYS_PATH}`

INSYNC=`timeout 30 /root/.local/share/solana/install/active_release/bin/solana catchup $KEYS_PATH http://127.0.0.1:8899 | grep caught`

if [[ -z ${INSYNC} ]]
then
 echo "`date` ALARM! node $ID_PUBKEY is out of sync"
  "/root/Send_msg_toTelBot.sh" "$HOSTNAME inform you:" "ALARM! Solana node is out of sync!"  2>&1 > /dev/null
else
 echo "`date` node $ID_PUBKEY is synced"
fi
