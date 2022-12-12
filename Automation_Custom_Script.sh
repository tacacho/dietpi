#!/bin/bash

# This file is executed after the successful installation of DietPi OS.
# My custom install happens.

# Install i3, i3lock, i3status, and suckless-tools
echo "Installing extras..."
apt-get install i3 i3lock i3status suckless-tools ranger lynx btop -y
