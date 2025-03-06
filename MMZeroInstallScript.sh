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

# Function to display progress
show_progress() {
    local message="$1"
    echo -e "\e[1;34m[INFO]\e[0m $message"
    sleep 1
    echo -e "\e[1;32m[✔]\e[0m $message"
}

# Enable debug mode for detailed logs
set -x

show_progress "Updating package list and upgrading..."
sudo apt update && sudo apt upgrade -y

show_progress "Removing existing Node.js versions..."
sudo apt remove -y nodejs npm

show_progress "Installing required dependencies..."
sudo apt install -y curl git build-essential

show_progress "Downloading and installing Node.js 20.18.1 for ARMv6 (community build)..."
NODE_VERSION="20.18.1" # Compatible version for MagicMirror
NODE_ARCH="armv6l"
NODE_DISTRO="linux"

cd ~
curl -fsSL "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-$NODE_DISTRO-$NODE_ARCH.tar.xz" -o node.tar.xz
mkdir -p ~/nodejs && tar -xJf node.tar.xz -C ~/nodejs --strip-components=1

show_progress "Setting environment variables for Node.js..."
export PATH=~/nodejs/bin:$PATH
echo 'export PATH=~/nodejs/bin:$PATH' >> ~/.bashrc

show_progress "Verifying Node.js and npm installation..."
node -v && npm -v

show_progress "Cloning MagicMirror repository if not present..."
git clone https://github.com/MichMich/MagicMirror ~/MagicMirror || echo "MagicMirror already exists"
@@ -67,14 +73,10 @@
cd ~/MagicMirror
npm install --omit=dev

show_progress "Setting up PM2 process manager..."
sudo npm install -g pm2
npm install

show_progress "Creating PM2 startup script..."
pm2 start ~/mmstart.sh --name "MagicMirror"
pm2 save
pm2 startup

show_progress "Installation complete. Rebooting system..."
sudo reboot
