#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

PUBKEY_VALI=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI})
INSYNC=$(timeout 30 ${APP_SOLANA} catchup ${KEY_VALI} http://127.0.0.1:8899 | grep caught)

if [[ -z ${INSYNC} ]]
then
 echo "`date` ALARM! NODE ${PUBKEY_VALI} is out of sync"
  "${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME inform you:" "ALARM! NODE ${PUBKEY_VALI} is out of sync!" 2>&1 > /dev/null
else
 echo "`date` NODE ${PUBKEY_VALI} is synced!"
fi
