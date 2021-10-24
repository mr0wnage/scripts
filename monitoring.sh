wget https://raw.githubusercontent.com/mr0wnage/scripts/main/Send_msg_toTelBot.sh -O /root/Send_msg_toTelBot.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-delinq.sh -O /root/solana-telegram-delinq.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-sync.sh -O /root/solana-telegram-sync.sh
chmod +x /root/Send_msg_toTelBot.sh
chmod +x /root/solana-telegram-delinq.sh
chmod +x /root/solana-telegram-sync.sh
clear; echo; echo "Dont forget:"; echo; echo "Edit /root/Send_msg_toTelBot.sh - token and chat ID"; echo "Edit /root/solana-telegram-delinq.sh - pubkey"; echo; echo "Add to CRONTAB (via crontab -e):"; echo; echo "*/15 * * * * /root/solana-telegram-delinq.sh"; echo "*/15 * * * * /root/solana-telegram-sync.sh"; echo
