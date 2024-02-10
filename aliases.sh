alias .catchup='while true; do time solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899/; sleep 15; done'
alias .skip='echo "DEV API:   $(solana block-production | grep $(solana address))"; echo "Local API: $(solana block-production --url http://localhost:8899 | grep $(solana address))"'
alias .validators='solana validators | grep "Stake By Version:" -A 20 -B 8'
alias .slotsum='solana leader-schedule | grep $(solana address) | wc -l'
alias .slot='while true; do solana slot; sleep 5; done'
alias .epoch='solana epoch-info'
alias .credits='solana validators -ul --sort=credits -r -n | sed -n 1,101p && solana validators -ul --sort=credits -r -n | grep -e $(solana address)'
alias .journal='journalctl -u solana.service -f -o cat | ccze'
alias .snap-mn='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 1000 --min_download_speed 50 && systemctl restart solana'
alias .snap-tds='systemctl stop solana && docker run -it --rm -v /root/solana/validator-ledger:/root/solana/validator-ledger --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /root/solana/validator-ledger --max_snapshot_age 500 --min_download_speed 50 -r http://api.testnet.solana.com && systemctl restart solana'
alias .snap-update='docker pull c29r3/solana-snapshot-finder:latest'

alias .mhz='watch -n 1 "cat /proc/cpuinfo | grep -i mhz"'

alias .balance='solana balance -k /root/solana/validator-keypair.json && solana balance -k /root/solana/vote-account-keypair.json && solana balance ??????????????????'

alias .stakes="echo 'Active Stake:'; .stakes_active; echo 'Activating Stake:'; .stakes_activates; echo 'Deactivating Stake:'; .stakes_deactivates"
alias .stakes_active="solana stakes /root/solana/vote-account-keypair.json | grep -w 'Active Stake:' | awk '{print \$3}' | awk '{s+=\$1} END {print s}'"
alias .stakes_activates="solana stakes /root/solana/vote-account-keypair.json | grep -i ' activates ' -A5 -B5 | grep Activating | awk '{s+=\$3} END {print s}'"
alias .stakes_deactivates="solana stakes /root/solana/vote-account-keypair.json | grep -i 'deactivates' -A5 -B5 | grep Balance | awk '{s+=\$2} END {print s}'"

alias .sfdp="solana-foundation-delegation-program list | grep $(solana address) -B1"
