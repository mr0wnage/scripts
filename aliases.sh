alias .catchup='while true; do time solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899/; sleep 15; done'
alias .skip='echo "DEV API:   $(solana block-production | grep $(solana address))"; echo "Local API: $(solana block-production --url http://localhost:8899 | grep $(solana address))"'
alias .validators='solana validators | grep "Stake By Version:" -A 20 -B 8'
alias .slotsum='solana leader-schedule | grep $(solana address) | wc -l'
alias .slotcurtds='while true; do solana slot -ut; sleep 5;done'
alias .slotcurmn='while true; do solana slot -um; sleep 5;done'
alias .epoch='solana epoch-info'
alias .journal='journalctl -u solana.service -f -o cat | ccze'
alias .snap-mn='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 1000 --min_download_speed 50 && systemctl restart solana'
alias .snap-tds='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 500 --min_download_speed 50 -r http://api.testnet.solana.com && systemctl restart solana'

alias .mhz='watch -n 1 "cat /proc/cpuinfo | grep -i mhz"'



alias .balance='solana balance -k /root/solana/validator-keypair.json && solana balance -k /root/solana/vote-account-keypair.json && solana balance ????????????'
