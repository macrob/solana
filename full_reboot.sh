#!/bin/bash

sudo service solana-tds stop

sudo apt update -y && sudo apt upgrade -y && sudo apt update -y && sudo apt upgrade -y

rm -rf /home/sol/ledger/ /home/sol/accounts/ /home/sol/logs/* /home/sol/snapshots/*

cd /home/sol/snapshots/ && wget --trust-server-names http://testnet.solana.com/snapshot.tar.bz2

cd /home/sol/snapshots/ && wget --trust-server-names http://testnet.solana.com/incremental-snapshot.tar.bz2

sleep 1

sudo reboot