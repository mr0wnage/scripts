#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

VALI_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VALI} | awk '{print $1}')
VOTE_BALANCE=$(${APP_SOLANA} balance -k ${KEY_VOTE} | awk '{print $1}')

ACTIVE_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -w "Active Stake:" | awk '{print $3}' | awk '{s+=$1} END {print s}')
ACTIVATING_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -i "activates" -B4 | grep Balance | awk '{print $2}' | paste -sd+ | bc)
DEACTIVATING_STAKE=$(${APP_SOLANA} stakes ${KEY_VOTE} | grep -i "deactivates" -B4 | grep Balance | awk '{print $2}' | paste -sd+ | bc)

"${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME inform you:" "Validator balance: $VALI_BALANCE Vote balance: $VOTE_BALANCE STAKEs: Active: $ACTIVE_STAKE Activating: $ACTIVATING_STAKE, Deactivating: $DEACTIVATING_STAKE" 2>&1 > /dev/null
