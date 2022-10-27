#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"
PUBKEY_VALI=`${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI}`
PUBKEY_VOTE=`${APP_SOLANA_KEYGEN} pubkey ${KEY_VOTE}`

VALI_BALANCE=$($APP_SOLANA balance -k ${KEY_VALI} | awk '{print $1}')
VOTE_BALANCE=$($APP_SOLANA balance -k ${KEY_VOTE} | awk '{print $1}')

ACTIVE_STAKE=$(solana stakes ${KEY_VOTE} | grep -w "Active Stake:" | awk '{print $3}' | awk '{s+=$1} END {print s}')
ACTIVATING_STAKE=$(solana stakes ${KEY_VOTE} | grep -i " activates" --color -A5 -B5 | grep Balance | awk '{print $2}' | paste -sd+ | bc)
DEACTIVATING_STAKE=$(solana stakes ${KEY_VOTE} | grep -i "deactivates" --color -A5 -B5 | grep Balance | awk '{print $2}' | paste -sd+ | bc)


"${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME inform you:" "Validator balance: $VALI_BALANCE Vote balance: $VOTE_BALANCE STAKEs: Active: $ACTIVE_STAKE Activating: $ACTIVATING_STAKE, Deactivating: $DEACTIVATING_STAKE" 2>&1 > /dev/null
