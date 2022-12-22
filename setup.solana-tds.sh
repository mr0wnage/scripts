#
# Last update 26/10/2022  version 1.14.5
#
### Ставим оптимизацию CPU

apt-get update && \
echo -e 'ENABLE="true"\nGOVERNOR="performance"' > /etc/default/cpufrequtils && \
apt-get install -y cpufrequtils moreutils && \
systemctl restart cpufrequtils.service && \
systemctl disable ondemand

### install mainnet beta (first install):
curl -sSf https://raw.githubusercontent.com/solana-labs/solana/v1.14.5/install/solana-install-init.sh | sh -s - v1.14.5

### Экспортнуть PATH или перезайти в терминал
export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Устанавливаем solana-sys-tuner.service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/service.solana-systuner -O /etc/systemd/system/solana-sys-tuner.service
chmod 0644 /etc/systemd/system/solana-sys-tuner.service
systemctl daemon-reload
systemctl enable solana-sys-tuner.service
systemctl restart solana-sys-tuner.service

# Устанавливаем service
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/service.solana-tds -O /etc/systemd/system/solana.service
chmod 0644 /etc/systemd/system/solana.service
systemctl daemon-reload
systemctl enable solana.service

### exclude solana-validator from rsyslog
echo 'if $programname == "solana-validator" then stop' > /etc/rsyslog.d/01-solana-remove.conf && systemctl restart rsyslog

### install prometheus-node-exporter 0.17.0+ds-3+b11 just because it works with my current dashboard
lsb_release -a 2>&1 | grep -q Ubuntu && \
wget http://http.us.debian.org/debian/pool/main/p/prometheus-node-exporter/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb -O /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
dpkg -i /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb && \
rm -rf /root/prometheus-node-exporter_0.17.0+ds-3+b11_amd64.deb

### https://docs.solana.com/running-validator/validator-monitor#timezone-for-log-messages
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

mkdir /root/solana
cd /root/solana

### generate identity - это уже сделали во время подачи заявки
###solana-keygen new --outfile ./validator-keypair.json
###cat validator-keypair.json &&echo

# Вариант А (просто переезд)
### создаём файлы ключей validator-keypair и vote-account-keypair
# На старой ноде:
cat /root/solana/validator-keypair.json
cat /root/solana/vote-account-keypair.json

# На новой ноде:
touch validator-keypair.json && chmod 0600 validator-keypair.json && echo edit validator-keypair.json && sleep 5 && nano validator-keypair.json
touch vote-account-keypair.json && chmod 0600 vote-account-keypair.json && echo edit vote-account-keypair.json && sleep 5 && nano vote-account-keypair.json


solana config set --url http://api.testnet.solana.com --keypair /root/solana/validator-keypair.json

solana balance

#### 10 сек смотрим на логи и потом ctrl-c
solana-gossip spy --entrypoint testnet.solana.com:8001

###create vote account ->>> https://docs.solana.com/running-validator/validator-start#create-vote-account
solana-keygen new -o /root/solana/vote-account-keypair.json

### делаем резервную копию
cat vote-account-keypair.json &&echo

### create account on blockchain
solana create-vote-account /root/solana/vote-account-keypair.json /root/solana/validator-keypair.json

### по результатам предыдущей команды должен быть примерно такой вывод:
#Signature: длиииииннный хэш транзакции

# проверить
solana vote-account /root/solana/vote-account-keypair.json

### должно быть что-то в этом роде - 3 раза должен быть показан pubkey основной
# Account Balance: 0.02685864 SOL
# Validator Identity: <YOUR_pubkey>
# Authorized Voters: {43: "<YOUR_pubkey>"}
# Authorized Withdrawer: <YOUR_pubkey>
# Credits: 0
# Commission: 100%
# Root Slot: ~
# Recent Timestamp: BlockTimestamp { slot: 0, timestamp: 0 }

systemctl start solana

journalctl -u solana.service -f --no-hostname | ccze

# Ставим систему мониторинга в КРОН

wget https://raw.githubusercontent.com/mr0wnage/scripts/main/setup.solana-monitoring.sh -O ~/setup.solana-monitoring.sh && bash ~/setup.solana-monitoring.sh && rm ~/setup.solana-monitoring.sh

# Запускам СКРИН с постоянной кетчапилкой
screen -S solana.catchup -h 1000000
# там запускаем
while true; do echo sleep 15 and try catchup; sleep 15; solana catchup /root/solana/validator-keypair.json http://127.0.0.1:8899/; done
# выходим через ctrl+a+d
# или что-то из этого в скрине, на свой выбор
while true; do echo "______________ $(TZ=UTC date) ______________"; du -sh /root/solana/validator-ledger/ 2>/dev/null; du -sh /root/solana/validator-ledger/accounts/ 2>/dev/null; timeout 30 solana catchup ~/solana/validator-keypair.json http://127.0.0.1:8899/ || echo timeout; timeout 30 solana block-production  --epoch $(solana epoch )  | grep -e " Identity Pubkey\|$(solana-keygen pubkey /root/solana/validator-keypair.json)"; sleep 60; done
while true; do echo "______________ $(TZ=UTC date) ______________"; du -sh /root/solana/validator-ledger/ 2>/dev/null; du -sh /root/solana/validator-ledger/accounts*/ 2>/dev/null; timeout 30 solana catchup ~/solana/validator-keypair.json http://127.0.0.1:8899/ || echo timeout; timeout 30 solana block-production  --epoch $(solana epoch )  | grep -e " Identity Pubkey\|$(solana-keygen pubkey /root/solana/validator-keypair.json)"; for i in $(seq 1 6); do for j in $(seq 1 30); do echo -ne .; sleep 1; done; echo -ne $(( i * j )); done; echo ""; done

### create stake keypair - https://docs.solana.com/running-validator/validator-stake#create-stake-keypair
solana-keygen new -o /root/solana/validator-stake-keypair.json

### бэкапим
cat validator-stake-keypair.json &&echo

### delegate to stake.acc
solana create-stake-account /root/solana/validator-stake-keypair.json 250

# delegate stake.acc to vote-account
solana delegate-stake /root/solana/validator-stake-keypair.json /root/solana/vote-account-keypair.json

# grep some info
solana validators | grep -e "$(solana-keygen pubkey /root/solana/validator-keypair.json)"

# теперь по нашему стейку
solana stakes | grep "$(solana-keygen pubkey /root/solana/validator-stake-keypair.json)" -A 10 -B 1

### устанавливаем комиссию
solana vote-update-commission /root/solana/vote-account-keypair.json 10 /root/solana/validator-keypair.json

### publish info about validator
solana validator-info publish "???" -n ??? -w "???" - d "???"

# example:
# solana validator-info publish "Elvis Validator" -n elvis -w "https://elvis-validates.com" -d "Some detail info here"

# monitoring
wget https://raw.githubusercontent.com/mr0wnage/scripts/main/setup.solana-monitoring.sh -O ~/setup.solana-monitoring.sh && bash ~/setup.solana-monitoring.sh && rm ~/setup.solana-monitoring.sh
