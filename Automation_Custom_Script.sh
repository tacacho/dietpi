#!/bin/bash

# This file is executed after the successful installation of DietPi OS.
# This script installs stuff

# Install i3, i3lock, i3status, and suckless-tools
echo "Installing i3, i3lock, i3status, and suckless-tools..."
apt-get install i3 i3lock i3status suckless-tools ranger lynx -y

# Install snapd
echo "Installing snapd..."
apt-get install snapd -y

# Install btop and fast using snap
echo "Installing btop using snap..."
snap install btop fast ncspot -y
