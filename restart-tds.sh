#!/bin/bash

sudo service solana-tds stop
rm -r $HOME/logs/*
rm -r $HOME/ledger/*
rm -r $HOME/snapshots/*

mkdir -p $HOME/logs
mkdir -p $HOME/ledger
mkdir -p $HOME/snapshots/

cd $HOME/snapshots/ && wget --trust-server-names http://api.testnet.solana.com/snapshot.tar.bz2
cd $HOME/ledger/ && wget --trust-server-names http://api.testnet.solana.com/genesis.tar.bz2
sleep 1

sudo service solana-tds start