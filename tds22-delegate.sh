#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/$1-validator-keypair.json"
KEY_TDS22="/root/solana/$1-tds22.json"

function alert_telegram() {
        local chat_id="***********************************"
        local token="***********************************"
        local text=$1
        local URL="https://api.telegram.org/bot$token"
        c_msg_send=$URL'/sendMessage'

        local BODY=$(curl -s "$c_msg_send" -d "chat_id=$chat_id" -d "text=$text")
}

if [[ -z $1 ]];
 then
  echo "Usage: $0 <!PERSON NICK!> <STAKE_ACCOUNT_ADDRESS> <VOTE_ACCOUNT_ADDRESS>"
  exit 0
 else
   if [[ -z $2 ]];
    then
     echo "Usage: $0 <!PERSON NICK!> <STAKE_ACCOUNT_ADDRESS> <VOTE_ACCOUNT_ADDRESS>"
     exit 0
    else
     if [[ -z $3 ]];
      then
       echo "Usage: $0 <!PERSON NICK!> <STAKE_ACCOUNT_ADDRESS> <VOTE_ACCOUNT_ADDRESS>"
       exit 0
     fi
   fi
fi

STAKE_ACC="$2"
VOTE_ACC="$3"

solana config set --url https://api.mainnet-beta.solana.com --keypair $KEY_VALI

$APP_SOLANA delegate-stake --stake-authority $KEY_TDS22 $STAKE_ACC $VOTE_ACC

alert_telegram "$1: $STAKE_ACC delegated to $VOTE_ACC!"
