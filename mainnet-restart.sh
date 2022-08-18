#!/bin/bash

sudo service solana-mainnet stop
rm -r $HOME/logs/*
rm -r $HOME/ledger/*
rm -r $HOME/snapshots/*

cd $HOME/snapshots/ && wget --trust-server-names http://api.mainnet-beta.solana.com/snapshot.tar.bz2
cd $HOME/snapshots/ && wget --trust-server-names http://api.mainnet-beta.solana.com/incremental-snapshot.tar.bz2
cd $HOME/ledger/ && wget --trust-server-names http://api.mainnet-beta.solana.com/genesis.tar.bz2
sleep 1

sudo service solana-mainnet start