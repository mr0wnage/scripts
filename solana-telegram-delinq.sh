#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

PUBKEY_VALI=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI})
PUBKEY_VOTE=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VOTE})

TG1="${HOSTNAME} delinq alert!"
TG2="Pubkey: <b>${PUBKEY_VALI}</b>"
TGBOT="${SCRIPT_DIR}/Send_msg_toTelBot.sh"

IS_DELINQUENT=$(timeout 30 ${APP_SOLANA} validators --output json | grep '"delinquent": true' -A 4 | grep ${PUBKEY_VALI})

if [[ -z ${IS_DELINQUENT} ]]
then
        echo "`date` Node ${PUBKEY_VALI} is NOT delinquent."
#        "${TGBOT}" "${TG1}" "${TG2}" "Node is <b>NOT</b> delinquent!" 2>&1 > /dev/null
else
        echo "`date` ALARM! NODE ${PUBKEY_VALI} is DELINQUENT!!!"
        "${TGBOT}" "${TG1}" "${TG2$}" "ALARM! Node is <b>DELINQUENT!</b>" 2>&1 > /dev/null
fi
