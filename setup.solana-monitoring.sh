wget https://raw.githubusercontent.com/mr0wnage/scripts/main/Send_msg_toTelBot.sh -O /root/Send_msg_toTelBot.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-balance.sh -O /root/solana-telegram-balance.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-delinq.sh -O /root/solana-telegram-delinq.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-skip.sh -O /root/solana-telegram-skip.sh
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/solana-telegram-sync.sh -O /root/solana-telegram-sync.sh
chmod +x /root/Send_msg_toTelBot.sh
chmod +x /root/solana-telegram-balance.sh
chmod +x /root/solana-telegram-delinq.sh
chmod +x /root/solana-telegram-skip.sh
chmod +x /root/solana-telegram-sync.sh
clear
echo
echo
crontab -l | 
    { 
        echo "# Solana cronjobs on $HOSTNAME" ;
        echo "#" ;
        echo "*/15 * * * * /root/solana-telegram-delinq.sh > /dev/null";
        echo "0 */6 * * * /root/solana-telegram-skip.sh > /dev/null";
        echo "*/15 * * * * /root/solana-telegram-sync.sh > /dev/null";
        echo "0 0 * * * /root/solana-telegram-balance.sh > /dev/null";
    } | crontab -
echo
echo "Dont forget:"
echo "Edit /root/Send_msg_toTelBot.sh - token and chat ID (nano /root/Send_msg_toTelBot.sh)"
