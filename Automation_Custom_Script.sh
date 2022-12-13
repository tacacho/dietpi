#!/bin/bash

# This file is executed after the successful installation of DietPi OS.
# This script installs stuff

# Install i3, i3lock, i3status, and suckless-tools
echo "Installing i3, i3lock, i3status, and suckless-tools..."
apt-get install i3 i3lock i3status suckless-tools python-pip ranger lynx snapd -y

# Install termv
echo "Installing termv..."
wget -O /usr/local/bin/termv -q --show-progress https://raw.githubusercontent.com/Roshan-R/termv/main/termv && chmod +x /usr/local/bin/termv

# Install castero using pip
echo "Installing castero..."
pip install castero -y

# Install btop and fast etc using snap
echo "Installing btop using snap..."
snap install btop fast ncspot -y

