# scripts
solana telegram alerts [DELINQUENT, SYNC, SKIP]

`Send_msg_toTelBot.sh`

`solana-telegram-delinq.sh`

`solana-telegram-skip.sh`

`solana-telegram-sync.sh`

права на исполнение

`chmod +x Send_msg_toTelBot.sh`

`chmod +x solana-telegram-*`

добавть в crontab

`crontab -e`

`*/15 * * * * /root/solana-telegram-delinq.sh > /dev/null`

`0 */6 * * * /root/solana-telegram-skip.sh > /dev/null`

`*/15 * * * * /root/solana-telegram-sync.sh > /dev/null`
