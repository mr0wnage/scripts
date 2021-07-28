#!/bin/bash

#solana-keygen pubkey ~/solana/validator-keypair.json
VALIDATOR_ADDR="_________________________"

IS_DELINQUENT=`timeout 30 /root/.local/share/solana/install/active_release/bin/solana validators --output json | grep '"delinquent": true' -A 4 | grep ${VALIDATOR_ADDR}`

if [[ -z ${IS_DELINQUENT} ]]
then
    echo "`date` node is synced"
else
    echo "`date` ALARM! node is out of sync"
  "/root/Send_msg_toTelBot.sh" "${HOSTNAME} inform you:" "ALARM! Solana validator ${VALIDATOR_ADDR} is delinquent"  2>&1 > /dev/null
fi
