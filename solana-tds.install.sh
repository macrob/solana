#!/bin/bash

echo 'install solana cli';

sh -c "$(curl -sSfL https://release.solana.com/v1.11.5/install)"
#solana config set --url https://api.mainnet-beta.solana.com
solana config set -u http://api.testnet.solana.com
solana config set --keypair ~/keys/validator-keypair.json



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


