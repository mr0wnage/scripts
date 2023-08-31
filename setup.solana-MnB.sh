#
# Last update 29/10/2022  version 1.13.4
#
### Настраиваем 
bash -c "cat >/etc/sysctl.d/21-solana-validator.conf <<EOF
# Increase UDP buffer sizes
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728

# Increase memory mapped files limit
vm.max_map_count = 1000000

# Increase number of allowed open file descriptors
fs.nr_open = 1000000
EOF"

sysctl -p /etc/sysctl.d/21-solana-validator.conf

# Add
LimitNOFILE=1000000
# to the [Service] section of your systemd service file, if you use one, otherwise add
DefaultLimitNOFILE=1000000
#to the [Manager] section of /etc/systemd/system.conf
systemctl daemon-reload

bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"

### Ставим оптимизацию CPU
apt-get update && echo -e 'ENABLE="true"\nGOVERNOR="performance"' > /etc/default/cpufrequtils && apt-get install -y cpufrequtils moreutils && systemctl restart cpufrequtils.service && systemctl disable ondemand

### Install mainnet beta  (first install)
curl -sSf https://raw.githubusercontent.com/solana-labs/solana/v1.13.4/install/solana-install-init.sh | sh -s - v1.13.4

### Экспортнуть PATH или перезайти в терминал
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Устанавливаем solana-sys-tuner.service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/service.solana-systuner -O /etc/systemd/system/solana-sys-tuner.service
chmod 0644 /etc/systemd/system/solana-sys-tuner.service
systemctl daemon-reload
systemctl enable solana-sys-tuner.service
systemctl restart solana-sys-tuner.service

# Устанавливаем solana.service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/service.solana-mnb -O /etc/systemd/system/solana.service
chmod 0644 /etc/systemd/system/solana.service
systemctl daemon-reload
systemctl enable solana.service

# Update
export ver_install=1.8.11 && \
solana-install init $ver_install && \
unset ver_install && \
systemctl restart solana-sys-tuner && \
echo version upgraded, sys-tuner restarted, solana service NOT restarted

### Исключаем solana-validator из rsyslog
echo 'if $programname == "solana-validator" then stop' > /etc/rsyslog.d/01-solana-remove.conf && systemctl restart rsyslog

### Устанавливаем prometheus-node-exporter 0.17.0+ds-3+b11 just because it works with my current dashboard
lsb_release -a 2>&1 | grep -q Ubuntu && \
wget http://http.us.debian.org/debian/pool/main/p/prometheus-node-exporter/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb -O /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
dpkg -i /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
rm -rf /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb

### Создаём tmpfs аккаунт 64GB
#mkdir -p /root/solana/validator-ledger/accounts
#echo 'tmpfs        /root/solana/validator-ledger/accounts tmpfs   nodev,nosuid,noexec,nodiratime,size=64G   0 0' >> /etc/fstab 
#mount  /root/solana/validator-ledger/accounts

### https://docs.solana.com/running-validator/validator-monitor#timezone-for-log-messages
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

mkdir /root/solana
cd /root/solana

### generate identity
###solana-keygen new --outfile ./validator-keypair.json
###cat validator-keypair.json &&echo
### создаём файл с ключом, который генерировали до этого

# Вариант А (просто переезд)
### создаём файлы ключей validator-keypair и vote-account-keypair
# На старой ноде:
cat /root/solana/validator-keypair.json
cat /root/solana/vote-account-keypair.json

# На новой ноде:
touch validator-keypair.json && chmod 0600 validator-keypair.json && echo edit validator-keypair.json && sleep 5 && nano validator-keypair.json
touch vote-account-keypair.json && chmod 0600 vote-account-keypair.json && echo edit vote-account-keypair.json && sleep 5 && nano vote-account-keypair.json

### Устанавливаем в конфиг сеть MN и ключ валидатора. 
solana config set --url https://api.mainnet-beta.solana.com --keypair /root/solana/validator-keypair.json

# Проверяем баланс
solana balance

# Шпионим в "сплетнях" ;-)
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

# Ставим систему мониторинга в КРОН

wget https://raw.githubusercontent.com/mr0wnage/scripts/main/setup.solana-monitoring.sh -O ~/setup.solana-monitoring.sh && bash ~/setup.solana-monitoring.sh && rm ~/setup.solana-monitoring.sh

# Запускам СКРИН с постоянной кетчапилкой
screen -S solana.catchup -h 1000000
# там запускаем
while true; do time solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899/; sleep 15; done
# выходим через ctrl+a+d
# или что-то из этого в скрине, на свой выбор
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
