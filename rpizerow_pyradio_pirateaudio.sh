#!/bin/bash

# BEGIN EDIT SECTION
# These are general instructions; adjust as needed based on your specific setup and requirements.

# NOTE: Ensure you have the right DietPi version (32-bit) for your Raspberry Pi model
# For RPi 3, DietPi should be installed correctly. Make sure you are using the correct build.

# Define variables if needed for URL or other configurations
PYRADIO_INSTALL_URL="https://raw.githubusercontent.com/coderholic/pyradio/master/pyradio/install.py"
STATIONS_URL="https://raw.githubusercontent.com/tacacho/radio/main/stations.csv"

# END EDIT SECTION

# System update and upgrade
echo "Updating and upgrading the system..."
apt update -y && apt upgrade -y

# Install required packages
echo "Installing additional packages..."
apt install -y cmake git mplayer mpv python3-full python3-pip python3-rich python3-requests python3-dnspython python3-psutil python3-netifaces python3-dateutil

# Clone and build fbcp-ili9341
echo "Cloning fbcp-ili9341 repository..."
cd ~
git clone https://github.com/juj/fbcp-ili9341.git
cd fbcp-ili9341
mkdir build
cd build
echo "Building fbcp-ili9341..."
cmake -DPIRATE_AUDIO_ST7789_HAT=ON -DSPI_BUS_CLOCK_DIVISOR=6 -DSTATISTICS=0 ..
make -j
echo "Installing fbcp-ili9341..."
sudo ./fbcp-ili9341

# Configure boot settings
echo "Configuring boot settings..."
# Comment out SPI and audio settings in boot config
sed -i '/^dtparam=spi=on/d' /boot/config.txt
sed -i '/^dtoverlay=audio/d' /boot/config.txt

# Add required settings to boot config
cat << EOF >> /boot/config.txt
display_rotate=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt=240 240 60 1 0 0 0
hdmi_force_hotplug=1
dtoverlay=hifiberry-dac
gpio=25=op,dh
EOF

# Install PyRadio
echo "Installing PyRadio..."
wget ${PYRADIO_INSTALL_URL} -O /tmp/install.py
python3 /tmp/install.py

# Configure PyRadio
echo "Configuring PyRadio..."
mkdir -p ~/.config/pyradio
curl ${STATIONS_URL} -o ~/.config/pyradio/stations.csv -f

# Adjust font size
echo "Adjusting font size..."
sed -i 's/FONTFACE=".*"/FONTFACE="Terminus"/' /etc/default/console-setup
sed -i 's/FONTSIZE=".*"/FONTSIZE="14x28"/' /etc/default/console-setup

# Make display work on reboot
echo "Configuring display to start on boot..."
sed -i '$i sudo /home/pi/fbcp-ili9341/build/fbcp-ili9341 &' /etc/rc.local

# Optional: Edit PyRadio server.py if needed
# You might want to provide instructions to edit this file manually if required
echo "You may need to edit /home/pi/.local/lib/python3.*/site-packages/pyradio/server.py to change the server."
echo "Also, ensure that PyRadio configuration is set to enable LAN control."

echo "Setup complete. Please reboot your system for changes to take effect."
