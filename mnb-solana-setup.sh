#
# Last update 24/10/2021  version 1.7.14
#
### Ставим оптимизацию CPU

apt-get update && \
echo -e 'ENABLE="true"\nGOVERNOR="performance"' > /etc/default/cpufrequtils && \
apt-get install -y cpufrequtils moreutils && \
systemctl restart cpufrequtils.service && \
systemctl disable ondemand

### Install mainnet beta  (first install)
curl -sSf https://raw.githubusercontent.com/solana-labs/solana/v1.7.14/install/solana-install-init.sh | sh -s - v1.7.14

### Экспортнуть PATH или перезайти в терминал
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Устанавливаем solana-sys-tuner.service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/service-file-solana-sys-tuner -O /etc/systemd/system/solana-sys-tuner.service
chmod 0644 /etc/systemd/system/solana-sys-tuner.service
systemctl daemon-reload
systemctl enable solana-sys-tuner.service 
systemctl restart solana-sys-tuner.service 

# Устанавливаем service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/mnb-solana.service -O /etc/systemd/system/solana.service
chmod 0644 /etc/systemd/system/solana.service
systemctl daemon-reload
systemctl enable solana.service 

# Update
export ver_install=1.7.14 && \
solana-install init $ver_install && \
unset ver_install && \
systemctl restart solana-sys-tuner && \
echo version upgraded, sys-tuner restarted, solana service NOT restarted

### exclude solana-validator from rsyslog
echo 'if $programname == "solana-validator" then stop' > /etc/rsyslog.d/01-solana-remove.conf && systemctl restart rsyslog

### install prometheus-node-exporter 0.17.0+ds-3+b11 just because it works with my current dashboard
lsb_release -a 2>&1 | grep -q Ubuntu && \
wget http://http.us.debian.org/debian/pool/main/p/prometheus-node-exporter/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb -O /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
dpkg -i /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
rm -rf /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb

### tmpfs accounts 64GB
#mkdir -p /root/solana/validator-ledger/accounts
#echo 'tmpfs        /root/solana/validator-ledger/accounts tmpfs   nodev,nosuid,noexec,nodiratime,size=64G   0 0' >> /etc/fstab 
#mount  /root/solana/validator-ledger/accounts

mkdir /root/solana
cd /root/solana

### generate identity
###solana-keygen new --outfile ./validator-keypair.json
###cat validator-keypair.json &&echo

### создаём файл с ключом, который генерировали до этого
touch validator-keypair.json && chmod 0600 validator-keypair.json && echo edit validator-keypair.json && sleep 5 && nano validator-keypair.json
solana config set --url https://api.mainnet-beta.solana.com --keypair /root/solana/validator-keypair.json
solana balance
solana-gossip spy --entrypoint mainnet-beta.solana.com:8001

### https://docs.solana.com/running-validator/validator-start#tune-system
##cat >/etc/sysctl.d/20-solana-udp-buffers.conf <<EOF
# Increase UDP buffer size
#net.core.rmem_default = 134217728
#net.core.rmem_max = 134217728
#net.core.wmem_default = 134217728
#net.core.wmem_max = 134217728
#EOF

#sysctl -p /etc/sysctl.d/20-solana-udp-buffers.conf

#cat >/etc/sysctl.d/20-solana-mmaps.conf <<EOF
## Increase memory mapped files limit
#vm.max_map_count = 1024000
#EOF

#sysctl -p /etc/sysctl.d/20-solana-mmaps.conf

###create vote account - https://docs.solana.com/running-validator/validator-start#create-vote-account
solana-keygen new -o /root/solana/vote-account-keypair.json

nano vote-account-keypair.json
cat vote-account-keypair.json &&echo

### create vote account on blockchain
solana create-vote-account /root/solana/vote-account-keypair.json /root/solana/validator-keypair.json

### устанавливаем ком-су
solana vote-update-commission /root/solana/vote-account-keypair.json 10 /root/solana/validator-keypair.json

systemctl start solana

journalctl -u solana -f --no-hostname | ccze
screen -S solana.catchup -h 1000000

while true; do echo "______________ $(TZ=UTC date) ______________"; du -sh /root/solana/validator-ledger/ 2>/dev/null; du -sh /root/solana/validator-ledger/accounts/ 2>/dev/null; timeout 30 solana catchup ~/solana/validator-keypair.json http://127.0.0.1:8899/ || echo timeout; timeout 30 solana block-production  --epoch $(solana epoch )  | grep -e " Identity Pubkey\|$(solana-keygen pubkey /root/solana/validator-keypair.json)"; sleep 60; done
while true; do echo "______________ $(TZ=UTC date) ______________"; du -sh /root/solana/validator-ledger/ 2>/dev/null; du -sh /root/solana/validator-ledger/accounts*/ 2>/dev/null; timeout 30 solana catchup ~/solana/validator-keypair.json http://127.0.0.1:8899/ || echo timeout; timeout 30 solana block-production  --epoch $(solana epoch )  | grep -e " Identity Pubkey\|$(solana-keygen pubkey /root/solana/validator-keypair.json)"; for i in $(seq 1 6); do for j in $(seq 1 30); do echo -ne .; sleep 1; done; echo -ne $(( i * j )); done; echo ""; done

### create stake keypair - https://docs.solana.com/running-validator/validator-stake#create-stake-keypair
solana-keygen new -o /root/solana/validator-stake-keypair.json
cat validator-stake-keypair.json &&echo

### delegate
solana create-stake-account /root/solana/validator-stake-keypair.json 100

solana delegate-stake /root/solana/validator-stake-keypair.json /root/solana/vote-account-keypair.json 

### view your vote account:
solana vote-account /root/solana/vote-account-keypair.json

###View your stake account, the delegation preference and details of your stake:
solana stake-account /root/solana/validator-stake-keypair.json

solana validators | grep -e "$(solana-keygen pubkey /root/solana/validator-keypair.json)"

### publish info about validator
solana validator-info publish "<some name that will show up in explorer>" -n <keybase_username> -w "<website>"
### example:
###solana validator-info publish "Elvis Validator" -n elvis -w "https://elvis-validates.com"
###solana validator-info publish "Elvis Validator" -n elvis
###solana validator-info publish "Elvis Validator" 

###
echo "export SOLANA_ADDRESS=$(solana-keygen pubkey /root/solana/validator-keypair.json)" | tee -a ~/.bashrc 
echo export SOLANA_VALIDATOR_INFO_PUBKEY=$(solana validator-info get | grep "$(solana-keygen pubkey /root/solana/validator-keypair.json)" -A5 | grep "Info Address" | head -n1 | awk '{ print $3}') | tee -a ~/.bashrc 
echo export SOLANA_VOTE_ADDRESS=$(solana validators  --output json | jq -r '.currentValidators[]  | select(.identityPubkey == "'$SOLANA_ADDRESS'") | .voteAccountPubkey') | tee -a ~/.bashrc 
source ~/.bashrc
clear && solana stakes $SOLANA_VOTE_ADDRESS   ; echo identity balance: $(solana balance); echo vote balance: $(solana balance $SOLANA_VOTE_ADDRESS)   ; solana epoch-info   ; solana block-production   | grep -e " Identity\|$SOLANA_ADDRESS" ; solana validator-info get $SOLANA_VALIDATOR_INFO_PUBKEY   ; solana validators   | grep -e "Identity\|$SOLANA_ADDRESS" ; echo "running: "$(curl -s -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getVersion"}' http://localhost:8899 | jq -r '.result."solana-core"' ); echo "installed: "$(solana -V)

###
while true; do echo "______________ $(TZ=UTC date) ______________"; du -sh /root/solana/validator-ledger/ 2>/dev/null; du -sh /root/solana/validator-ledger/accounts*/ 2>/dev/null; timeout 30 solana catchup $SOLANA_ADDRESS http://127.0.0.1:8899/ || echo timeout; timeout 30 solana block-production    | grep -e " Identity \|$SOLANA_ADDRESS"; for i in $(seq 1 6); do for j in $(seq 1 30); do echo -ne .; sleep 1; done; echo -ne $(( i * j )); done; echo ""; done

# monitoring
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/monitoring.sh -O ~/monitoring.sh && bash ~/monitoring.sh
