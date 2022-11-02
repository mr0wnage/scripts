#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

PUBKEY_VALI=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI})
PUBKEY_VOTE=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VOTE})

TG1="${HOSTNAME} sol alert!"
TG2="Pubkey: <b>${PUBKEY_VALI}</b>"
TGBOT="${SCRIPT_DIR}/Send_msg_toTelBot.sh"

#VALI_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VALI} | awk '{printf("%d\n", $1+0.5)}')
#VOTE_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VOTE} | awk '{printf("%d\n", $1+0.5)}')
VALI_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VALI} | awk '{printf("%.2f \n", $1)}')
VOTE_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VOTE} | awk '{printf("%.2f \n", $1)}')

ACTIVE_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -w "Active Stake:" | awk '{print $3}' | awk '{s+=$1} END {printf("%d\n", s+0.5)}')
ACTIVATING_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -i " activates" -B4 | grep Balance | awk '{printf("%d\n", $2+0.5)}' | paste -sd+ | bc)
DEACTIVATING_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -i "deactivates" -B4 | grep Balance | awk '{printf("%d\n", $2+0.5)}' | paste -sd+ | bc)

echo "`date` $PUBKEY_VALI BALANCE: validator - $VALI_BALANCE vote - $VOTE_BALANCE STAKE: active - $ACTIVE_STAKE activating - $ACTIVATING_STAKE deactivating - $DEACTIVATING_STAKE"
"${TGBOT}" "${TG1}" "${TG2}" "BALANCE: validator - $VALI_BALANCE vote - $VOTE_BALANCE %0ASTAKE: active - $ACTIVE_STAKE activating - $ACTIVATING_STAKE deactivating - $DEACTIVATING_STAKE" 2>&1 > /dev/null
