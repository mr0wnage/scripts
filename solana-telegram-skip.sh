#!/bin/bash
SCRIPT_DIR="/root/"
APP_SOLANA="/root/.local/share/solana/install/active_release/bin/solana"
APP_SOLANA_KEYGEN="/root/.local/share/solana/install/active_release/bin/solana-keygen"
KEY_VALI="/root/solana/validator-keypair.json"
KEY_VOTE="/root/solana/vote-account-keypair.json"

PUBKEY_VALI=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VALI})
PUBKEY_VOTE=$(${APP_SOLANA_KEYGEN} pubkey ${KEY_VOTE})

SKIP=$(${APP_SOLANA} block-production | grep -e ${PUBKEY_VALI})
SKIP_PERCENT=$(echo ${SKIP} | gawk '{print $NF}')
SKIP_PERCENT=${SKIP_PERCENT%"%"}

SKIP_TOTAL=$(${APP_SOLANA} block-production | grep -e total)
SKIP_PERCENT_TOTAL=$(echo ${SKIP_TOTAL} | gawk '{print $NF}')
SKIP_PERCENT_TOTAL=${SKIP_PERCENT_TOTAL%"%"}

echo "my skip ${SKIP_PERCENT}"
echo "avg skip ${SKIP_PERCENT_TOTAL}"

if [[ ${SKIP_PERCENT} = "" ]]
then
        "${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME skip alert!" "Pubkey: <b>${PUBKEY_VALI}</b>" "Pizda rulu" 2>&1 > /dev/null
else
if (( $(echo "${SKIP_PERCENT} < ${SKIP_PERCENT_TOTAL}" | bc -l) ))
then
        echo "`date` NODE ${PUBKEY_VALI} skiprate is below average."
        "${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME skip alert!" "Pubkey: <b>${PUBKEY_VALI}</b>" "Node skiprate ${SKIP_PERCENT}% is <b>BELOW</b> average ${SKIP_PERCENT_TOTAL}%." 2>&1 > /dev/null
else
        echo "`date` ALARM! NODE ${PUBKEY_VALI} skiprate is above average!!!"
        "${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME skip alert!" "Pubkey: <b>${PUBKEY_VALI}</b>" "ALARM!!! Node skiprate ${SKIP_PERCENT}% is <b>ABOVE</b> average ${SKIP_PERCENT_TOTAL}%!!!" 2>&1 > /dev/null
fi
fi
