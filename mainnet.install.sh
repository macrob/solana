#!/bin/bash

echo 'install solana cli';

sh -c "$(curl -sSfL https://release.solana.com/v1.10.35/install)"
export PATH="/home/sol/.local/share/solana/install/active_release/bin:$PATH"

#solana config set --url https://api.mainnet-beta.solana.com
solana config set --url https://api.mainnet-beta.solana.com
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
	sudo bash -c "cat >/etc/logrotate.d/solana-mainnet <<EOF
/home/sol/logs/solana-validator.log {
  su sol sol
  rotate 7
  daily
  missingok
  postrotate
    systemctl kill -s USR1 solana-mainnet.service
  endscript
}
EOF"

sudo service logrotate restart


sudo ln -s /home/sol/solana/solana-mainnet.service /etc/systemd/system/

sudo systemctl enable --now solana-mainnet
sudo service solana-mainnet start
sudo service solana-mainnet status