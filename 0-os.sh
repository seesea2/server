#!/bin/bash

# Generate locale
sudo locale-gen en_US.UTF-8
# set timezone
sudo dpkg-reconfigure tzdata
sudo restart_service rsyslog

source config.conf

# set hostname
sudo echo $myHost >/etc/hostname
sudo hostname $myHost

# upgrade OS and install basic tools
sudo echo upgrade OS and install basic tools
sudo apt update && sudo apt upgrade -y && sudo apt autoremove
sudo apt-get install -y git curl wget

