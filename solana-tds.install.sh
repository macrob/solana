#!/bin/bash

echo 'install solana cli';

sh -c "$(curl -sSfL https://release.solana.com/v1.11.5/install)"
#solana config set --url https://api.mainnet-beta.solana.com
solana config set -u http://api.testnet.solana.com
solana config set --keypair ~/keys/validator-keypair.json



sudo bash -c "cat >/home/sol/sys-tuner.service <<EOF
[Unit]
Description=Solana sys-tuner
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/home/sol/.local/share/solana/install/active_release/bin/solana-sys-tuner --user sol

[Install]
WantedBy=multi-user.target
EOF"

sudo ln -s /home/sol/sys-tuner.service /etc/systemd/system/
sudo systemctl enable --now sys-tuner
sudo service sys-tuner start
sudo service sys-tuner status


echo 'install log rotate';
	sudo bash -c "cat >/etc/logrotate.d/solana-tds <<EOF
/home/sol/logs/solana-validator.log {
  su sol sol
  rotate 7
  daily
  missingok
  postrotate
    systemctl kill -s USR1 solana-tds.service
  endscript
}
EOF"
sudo service logrotate restart


sudo ln -s /home/sol/solana/solana-tds.service /etc/systemd/system/
sudo systemctl enable --now solana-tds
sudo service solana-tds start
sudo service solana-tds status