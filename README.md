# scripts
solana telegram alerts [DELINQUENT, SYNC]

`Send_msg_toTelBot.sh`
`solana-telegram-delinq.sh`
`solana-telegram-sync.sh`

права на исполнение
`chmod +x Send_msg_toTelBot.sh`
`chmod +x solana-telegram-*`

добавть в crontab
`crontab -e`

`*/15 * * * * /root/solana-telegram-delinq.sh

*/15 * * * * /root/solana-telegram-sync.sh`
