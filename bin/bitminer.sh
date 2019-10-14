#!/bin/bash

add-apt-repository -y ppa:bitcoin/bitcoin
apt-get -y update
apt-get -y install bitcoin-qt
