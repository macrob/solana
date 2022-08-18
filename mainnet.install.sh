#!/bin/bash
sudo ln -s /home/sol/solana/solana-mainnet.service /etc/systemd/system/

sudo systemctl enable --now solana-mainnet
sudo service solana-mainnet start
sudo service solana-mainnet status