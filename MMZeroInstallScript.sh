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

# Update package list
sudo apt update && sudo apt upgrade -y

# Remove existing Node.js versions if any
sudo apt remove -y nodejs npm

# Install required dependencies
sudo apt install -y curl git build-essential

# Download and install Node.js 20 for ARMv6 (community build)
NODE_VERSION="20.9.0" # Update to latest stable ARMv6 build
NODE_ARCH="armv6l"
NODE_DISTRO="linux"

cd ~
curl -fsSL "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-$NODE_DISTRO-$NODE_ARCH.tar.xz" -o node.tar.xz
mkdir -p ~/nodejs && tar -xJf node.tar.xz -C ~/nodejs --strip-components=1

# Set environment variables for Node.js
export PATH=~/nodejs/bin:$PATH
echo 'export PATH=~/nodejs/bin:$PATH' >> ~/.bashrc

# Verify installation
node -v
npm -v

# Clone MagicMirror repository if not present
git clone https://github.com/MichMich/MagicMirror ~/MagicMirror || echo "MagicMirror already exists"

# Install MagicMirror dependencies
cd ~/MagicMirror
npm install --omit=dev

# Setup PM2 process manager
sudo npm install -g pm2
pm install

# Create PM2 startup script
pm2 start ~/mmstart.sh --name "MagicMirror"
pm2 save
pm2 startup

# Reboot system
echo "Installation complete. Rebooting..."
sudo reboot
