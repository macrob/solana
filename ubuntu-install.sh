#!/bin/bash

apt update && apt upgrade -y

apt install git -y

mkdir ~/.ssh

## KEY выглядит примерно так ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb9Zf1NQaWgaVXXls1WI5MRsubYi2WB2VjFzlAfEO38a+NFEbwqkOGwayUtsncIamn7jB5Hni8D72DuOFqWPYcdbiEapryvtNq0HesjLkqkby/8k+2NRiEf29Z/ujFnMtRS+cXDdpcSkcMcWLcHWMUkH1AzRYYxnSPLUMq4j4pHQ3jpJPNTSKqAsFRamEyMmaY9U+Ft5qfKNO7Fe7fJyZvPmdJ/2SlV9Zjd9C9rS80IwNeZ9B8m5R4roMnx3h9BOHYtX47zco0gu0mlRVMSYzLD5uDSfz/F5Tb7qJdqvwjCAZZdcLlwd5lg/6QrE+kM9O/Jr0UDbwldc9paA2OGNA7 rsa 2048
echo 'Setup ssh config';
echo 'KEY' >> .ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb9Zf1NQaWgaVXXls1WI5MRsubYi2WB2VjFzlAfEO38a+NFEbwqkOGwayUtsncIamn7jB5Hni8D72DuOFqWPYcdbiEapryvtNq0HesjLkqkby/8k+2NRiEf29Z/ujFnMtRS+cXDdpcSkcMcWLcHWMUkH1AzRYYxnSPLUMq4j4pHQ3jpJPNTSKqAsFRamEyMmaY9U+Ft5qfKNO7Fe7fJyZvPmdJ/2SlV9Zjd9C9rS80IwNeZ9B8m5R4roMnx3h9BOHYtX47zco0gu0mlRVMSYzLD5uDSfz/F5Tb7qJdqvwjCAZZdcLlwd5lg/6QrE+kM9O/Jr0UDbwldc9paA2OGNA7 rsa 2048' >> ~/.ssh/authorized_keys

sudo sed -i "s/#Port 22/Port 3784/" /etc/ssh/sshd_config
sudo sed -i -r 's/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config
sudo service sshd restart;

sudo apt install ufw curl fail2ban fish gawk jq gnupg2 git htop ncdu qt -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 3784
sudo ufw allow 8000:8020/tcp #solana port
sudo ufw allow 8000:8020/udp #solana port
sudo ufw allow 8899 # solaba rpc port

sudo ufw enable
sudo ufw disable

#### create user AS root
echo 'Setup user sol';
sudo adduser sol
sudo adduser sol sudo

sudo usermod -aG sudo sol

echo 'Add system tuning';

sudo bash -c "cat >/etc/sysctl.d/21-solana-validator.conf <<EOF
# Increase UDP buffer sizes
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728

# Increase memory mapped files limit
vm.max_map_count = 1000000

# Increase number of allowed open file descriptors
fs.nr_open = 1000000
EOF";

sudo sysctl -p /etc/sysctl.d/21-solana-validator.conf;

cat >> /etc/systemd/system.conf <<EOL
DefaultLimitNOFILE=1000000
[Service]
LimitNOFILE=1000000
EOL;

sudo systemctl daemon-reload;

sudo bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"

echo 'END system tuning';

echo 'Instal cpu tunning';
sudo apt install cpufrequtils linux-tools-generic
sudo cpupower frequency-set -g performance

su - sol
mkdir logs ledger
mkdir ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb9Zf1NQaWgaVXXls1WI5MRsubYi2WB2VjFzlAfEO38a+NFEbwqkOGwayUtsncIamn7jB5Hni8D72DuOFqWPYcdbiEapryvtNq0HesjLkqkby/8k+2NRiEf29Z/ujFnMtRS+cXDdpcSkcMcWLcHWMUkH1AzRYYxnSPLUMq4j4pHQ3jpJPNTSKqAsFRamEyMmaY9U+Ft5qfKNO7Fe7fJyZvPmdJ/2SlV9Zjd9C9rS80IwNeZ9B8m5R4roMnx3h9BOHYtX47zco0gu0mlRVMSYzLD5uDSfz/F5Tb7qJdqvwjCAZZdcLlwd5lg/6QrE+kM9O/Jr0UDbwldc9paA2OGNA7 rsa 2048' >> ~/.ssh/authorized_keys


echo 'install cpu service';

sudo bash -c "cat >/home/sol/cpupower.service <<EOF
[Unit]

Description=CPU performance

[Service]

Type=oneshot

ExecStart=/usr/bin/cpupower -c all frequency-set -g performance

[Install]

WantedBy=multi-user.target
EOF"

sudo ln -s /home/sol/cpupower.service /etc/systemd/system/

sudo systemctl enable --now cpupower.service
sudo service cpupower start
sudo service cpupower status
