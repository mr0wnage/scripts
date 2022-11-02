#!/bin/bash

telegram_bot_token="_______REPLACE_ME________"
telegram_chat_id="_______REPLACE_ME________"

Title="$1"
Message1="$2"
Message2="$3"

curl -s \
 --data parse_mode=HTML \
 --data chat_id=${telegram_chat_id} \
 --data text="<b>${Title}</b>%0A${Message1}%0A${Message2}" \
 --request POST https://api.telegram.org/bot${telegram_bot_token}/sendMessage
