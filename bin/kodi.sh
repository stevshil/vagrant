#!/bin/bash

sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt-get -y update
sudo apt-get -y install kodi
sudo apt-get -y purge libreoffice-* rhythmbox* cheese* gnome-mahjongg gnome-mines shotwell simple-scan gnome-sudoku totem cups*
sudo apt-get -y update
sudo apt-get -y upgrade
