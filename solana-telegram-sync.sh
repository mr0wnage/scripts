#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

PUBKEY_VALI=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI})
PUBKEY_VOTE=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VOTE})

TG1="${HOSTNAME} <i>SYNC</i> alert!"
TG2="Pubkey: <code>${PUBKEY_VALI}</code>"
TGBOT="${SCRIPT_DIR}/Send_msg_toTelBot.sh"

INSYNC=$(timeout 30 ${APP_SOLANA} catchup ${KEY_VALI} http://127.0.0.1:8899 | grep caught)

if [[ -z ${INSYNC} ]]
then
        echo "`date` ALARM! Node ${PUBKEY_VALI} is OUT of sync!!!"
        "${TGBOT}" "${TG1}" "${TG2}" "<b>ALARM!!!</b> Node is <code>OUT OF SYNC</code>!" 2>&1 > /dev/null
else
        echo "`date` Node ${PUBKEY_VALI} is synced."
        "${TGBOT}" "${TG1}" "${TG2}" "Node is <code>SYNCED</code>." 2>&1 > /dev/null
fi
