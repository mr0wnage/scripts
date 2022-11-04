alias .catchup='while true; do time solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899/; sleep 15; done'
alias .skip='echo "DEV API:   $(solana block-production | grep $(solana address))"; echo "Local API: $(solana block-production --url http://localhost:8899 | grep $(solana address))"'
alias .validators='solana validators | grep "Stake By Version:" -A 20 -B 8'
alias .slotsum='solana leader-schedule | grep $(solana address) | wc -l'
alias .epoch='solana epoch-info'
alias .journal='journalctl -u solana.service -f -o cat | ccze'
alias .snap-mn='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 1000 --min_download_speed 50 && systemctl restart solana'
alias .snap-tds='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 500 --min_download_speed 50 -r http://api.testnet.solana.com && systemctl restart solana'

alias .mhz='watch -n 1 "cat /proc/cpuinfo | grep -i mhz"'







alias .stakes=$(..stakes),$(..astakes),$(..dstakes)
alias ..stakes="echo 'Active Stake:' && solana stakes /root/solana/vote-account-keypair.json | grep -w 'Active Stake:' | awk '{print $3}' | awk '{s+=$1} END {print s}'"
alias ..astakes="echo 'Activating Stake:' && solana stakes /root/solana/vote-account-keypair.json | grep -i 'activates' -A5 -B5 | grep Balance | awk '{print $2}' | paste -sd+ | bc"
alias ..dstakes="echo 'Deactivating Stake:' && solana stakes /root/solana/vote-account-keypair.json | grep -i 'deactivates' -A5 -B5 | grep Balance | awk '{print $2}' | paste -sd+ | bc"
