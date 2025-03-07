#!/bin/bash
#
# Copyright 2025 Achim Pieters | StudioPieters®
#
# More information on https://Studiopieters.nl
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#!/bin/bash
#
# Copyright 2025 Achim Pieters | StudioPieters®
#
# More information on https://Studiopieters.nl
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -e  # Exit on error
set -x  # Enable debug mode for detailed logs

# Function to display progress
show_progress() {
    local message="$1"
    echo -e "\e[1;34m[INFO]\e[0m $message"
    sleep 1
    echo -e "\e[1;32m[✔]\e[0m $message"
}

# Update and upgrade system packages
show_progress "Updating package list and upgrading..."
sudo apt update && sudo apt upgrade -y

# Ensure HDMI output is enabled for Raspberry Pi Zero W
show_progress "Configuring HDMI output..."
sudo sed -i 's/^#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
sudo sed -i 's/^#hdmi_group=1/hdmi_group=2/' /boot/config.txt
sudo sed -i 's/^#hdmi_mode=1/hdmi_mode=82/' /boot/config.txt
echo "hdmi_force_hotplug=1" | sudo tee -a /boot/config.txt

# Remove old Node.js versions
show_progress "Removing existing Node.js versions..."
sudo apt remove -y nodejs npm

# Install required dependencies
show_progress "Installing required dependencies..."
sudo apt install -y curl git build-essential xserver-xorg xinit unclutter chromium-browser 

# Install Node.js (Community Build for ARMv6)
show_progress "Downloading and installing Node.js 20.18.1..."
NODE_VERSION="20.18.1"
NODE_ARCH="armv6l"
NODE_DISTRO="linux"

cd ~
curl -fsSL "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-$NODE_DISTRO-$NODE_ARCH.tar.xz" -o node.tar.xz
mkdir -p ~/nodejs && tar -xJf node.tar.xz -C ~/nodejs --strip-components=1

# Set environment variables
show_progress "Setting environment variables for Node.js..."
export PATH=$HOME/nodejs/bin:$PATH
echo 'export PATH=$HOME/nodejs/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Create system-wide links for Node.js & npm (so sudo can find them)
sudo ln -sf ~/nodejs/bin/node /usr/bin/node
sudo ln -sf ~/nodejs/bin/npm /usr/bin/npm

# Verify installation
show_progress "Verifying Node.js and npm installation..."
node -v && npm -v

# Clone MagicZeroMirror repository
show_progress "Cloning MagicZeroMirror repository if not present..."
if [ ! -d "/home/pi/MagicZeroMirror" ]; then
    git clone https://github.com/AchimPieters/MagicZeroMirror /home/pi/MagicZeroMirror
else
    echo "MagicZeroMirror already exists, skipping clone."
fi

# Clone MagicMirror repository
show_progress "Cloning MagicMirror repository if not present..."
if [ ! -d "$HOME/MagicMirror" ]; then
    git clone https://github.com/MichMich/MagicMirror ~/MagicMirror
else
    echo "MagicMirror already exists, skipping clone."
fi

# Install MagicMirror dependencies
show_progress "Installing MagicMirror dependencies..."
cd ~/MagicMirror
npm install --omit=dev

# Install PM2 properly
show_progress "Installing PM2 process manager..."
npm install -g pm2 --unsafe-perm

# Ensure PM2 is properly configured
show_progress "Creating PM2 startup script..."
pm2 start /home/pi/MagicZeroMirror/mmstart.sh --name "MagicMirror"
pm2 save
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u pi --hp /home/pi

# Set up autostart for Magic Mirror
show_progress "Setting up autostart for Magic Mirror..."
echo "@xinit /home/pi/MagicZeroMirror/mmstart.sh" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart

# Final reboot
show_progress "Installation complete. Rebooting system..."
sudo reboot
