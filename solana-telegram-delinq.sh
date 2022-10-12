#!/bin/bash
SCRIPT_DIR=/root/
APP_SOLANA=/root/.local/share/solana/install/active_release/bin/solana
APP_SOLANA_KEYGEN=/root/.local/share/solana/install/active_release/bin/solana-keygen
KEYS_PATH=/root/solana/validator-keypair.json
ID_PUBKEY=`${APP_SOLANA_KEYGEN} pubkey ${KEYS_PATH}`

IS_DELINQUENT=`timeout 30 /root/.local/share/solana/install/active_release/bin/solana validators --output json | grep '"delinquent": true' -A 4 | grep ${ID_PUBKEY}`

if [[ -z ${IS_DELINQUENT} ]]
then
    echo "`date` node ${ID_PUBKEY} is NOT delinquent!"
else
    echo "`date` ALARM! Node is DELINQUENT!"
  "/root/Send_msg_toTelBot.sh" "${HOSTNAME} inform you:" "ALARM! Solana validator ${ID_PUBKEY} is delinquent"  2>&1 > /dev/null
fi
