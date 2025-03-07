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

# Ensure script is run with sudo or root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[1;31m[ERROR]\e[0m This script must be run as root (or use sudo)." 
    exit 1
fi

# Function to display progress
show_progress() {
    local message="$1"
    echo -e "\e[1;34m[INFO]\e[0m $message"
    sleep 1
    echo -e "\e[1;32m[\xE2\x9C\x94]\e[0m $message"
}

# Update and upgrade system packages
show_progress "Updating package list and upgrading..."
sudo apt update && sudo apt upgrade -y

# Check and remove old Node.js versions if they exist
if command -v node &>/dev/null; then
    show_progress "Removing existing Node.js versions..."
    sudo apt remove -y nodejs npm
else
    show_progress "No existing Node.js found, skipping removal."
fi

# Install required dependencies
show_progress "Installing required dependencies..."
sudo apt install -y curl git build-essential

# Install Node.js (Community Build for ARMv6)
show_progress "Downloading and installing Node.js 20.18.1..."
NODE_VERSION="20.18.1"
NODE_ARCH="armv6l"
NODE_DISTRO="linux"

cd ~
if ! curl -fsSL "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-$NODE_DISTRO-$NODE_ARCH.tar.xz" -o node.tar.xz; then
    echo -e "\e[1;31m[ERROR]\e[0m Failed to download Node.js."
    exit 1
fi

mkdir -p ~/nodejs && tar -xJf node.tar.xz -C ~/nodejs --strip-components=1

# Set environment variables
show_progress "Setting environment variables for Node.js..."
export PATH=$HOME/nodejs/bin:$PATH
if ! grep -q "export PATH=\$HOME/nodejs/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=$HOME/nodejs/bin:$PATH' >> ~/.bashrc
fi
exec bash

# Create system-wide links for Node.js & npm (so sudo can find them)
sudo ln -sf ~/nodejs/bin/node /usr/bin/node
sudo ln -sf ~/nodejs/bin/npm /usr/bin/npm

# Verify Node.js installation
if ! command -v node &>/dev/null; then
    echo -e "\e[1;31m[ERROR]\e[0m Node.js installation failed."
    exit 1
fi
show_progress "Node.js and npm installed successfully."
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Clone MagicZeroMirror repository if not present
show_progress "Cloning MagicZeroMirror repository if not present..."
if [ ! -d "/home/pi/MagicZeroMirror" ]; then
    git clone https://github.com/AchimPieters/MagicZeroMirror /home/pi/MagicZeroMirror
else
    echo "MagicZeroMirror already exists, skipping clone."
fi

# Clone MagicMirror repository if not present
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

# Install PM2 process manager
show_progress "Installing PM2 process manager..."
npm install -g pm2 --unsafe-perm

# Ensure PM2 is properly configured
show_progress "Creating PM2 startup script..."
pm2 start $HOME/MagicZeroMirror/mmstart.sh --name "MagicMirror"
pm2 save

# Use full path for PM2 startup and execute the command directly
STARTUP_CMD=$(pm2 startup systemd -u pi --hp /home/pi | tail -n 1)
eval "$STARTUP_CMD"

# Final reboot with a short delay
show_progress "Installation complete. Rebooting system in 5 seconds..."
sleep 5
sudo reboot now
