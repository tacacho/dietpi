#!/bin/bash

# BEGIN EDIT SECTION
# Update these URLs if necessary based on your setup
PYRADIO_INSTALL_URL="https://raw.githubusercontent.com/coderholic/pyradio/master/pyradio/install.py"
STATIONS_URL="https://raw.githubusercontent.com/tacacho/radio/main/stations.csv"
FBP_DIR=~/fbcp-ili9341
FBP_BUILD_DIR=$FBP_DIR/build
FBP_BINARY=$FBP_BUILD_DIR/fbcp-ili9341
# END EDIT SECTION

# System update and upgrade
echo "Updating and upgrading the system..."
sudo apt update -y && sudo apt upgrade -y

# Install required packages
echo "Installing additional packages..."
sudo apt install -y cmake git mplayer mpv python3-full python3-pip python3-rich python3-requests python3-dnspython python3-psutil python3-netifaces python3-dateutil

# Clone and build fbcp-ili9341
echo "Cloning fbcp-ili9341 repository..."
cd ~
git clone https://github.com/juj/fbcp-ili9341.git
cd fbcp-ili9341

echo "Creating build directory..."
mkdir -p build
cd build

echo "Building fbcp-ili9341..."
cmake -DPIRATE_AUDIO_ST7789_HAT=ON -DSPI_BUS_CLOCK_DIVISOR=6 -DSTATISTICS=0 ..
make -j

echo "Installing fbcp-ili9341..."
if [ -f "$FBP_BINARY" ]; then
    sudo $FBP_BINARY
else
    echo "Error: fbcp-ili9341 binary not found. Build may have failed." >&2
    exit 1
fi

# Configure boot settings
echo "Configuring boot settings..."
# Remove existing settings if present
sudo sed -i '/^dtparam=spi=on/d' /boot/config.txt
sudo sed -i '/^dtoverlay=audio/d' /boot/config.txt

# Add new settings
cat << EOF | sudo tee -a /boot/config.txt
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
wget $PYRADIO_INSTALL_URL -O /tmp/install.py
# Avoid running PyRadio install script as root
echo "Running PyRadio install script as a regular user..."
python3 /tmp/install.py

# Configure PyRadio
echo "Configuring PyRadio..."
mkdir -p ~/.config/pyradio
curl $STATIONS_URL -o ~/.config/pyradio/stations.csv -f

# Adjust font size
echo "Adjusting font size..."
sudo apt install -y fonts-terminus
sudo sed -i 's/FONTFACE=".*"/FONTFACE="Terminus"/' /etc/default/console-setup
sudo sed -i 's/FONTSIZE=".*"/FONTSIZE="14x28"/' /etc/default/console-setup

# Make display work on reboot
echo "Configuring display to start on boot..."
sudo sed -i '$i sudo /home/pi/fbcp-ili9341/build/fbcp-ili9341 &' /etc/rc.local

# Configure PyRadio to start on boot
echo "Configuring PyRadio to start on boot..."
cat << EOF | sudo tee -a /etc/rc.local
# Start PyRadio
/usr/bin/python3 /home/pi/.local/lib/python3.*/site-packages/pyradio/pyradio.py &
EOF

# Inform the user that setup is complete and the system will reboot
echo "Setup complete. The system will reboot now to apply changes."

# Reboot the system
sudo reboot
