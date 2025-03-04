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

set -e  # Exit on failure

echo 'Downloading MagicMirror Raspberry Pi Zero W installation files'
git clone --recursive https://github.com/AchimPieters/MagicZeroMirror.git || { echo "Failed to clone repository"; exit 1; }

echo 'Updating Raspberry Pi...'
sudo apt-get update -y && sudo apt-get upgrade -y --fix-missing

echo 'Installing dependencies...'
sudo apt install -y npm git xinit xorg matchbox unclutter chromium-browser

echo 'Downloading and installing Node.js (v20.18.1 for ARMv6)'
NODE_VERSION="v20.18.1"
NODE_ARCH="linux-armv6l"
NODE_TAR="node-${NODE_VERSION}-${NODE_ARCH}.tar.xz"

wget -q --show-progress "https://unofficial-builds.nodejs.org/download/release/${NODE_VERSION}/${NODE_TAR}"
tar xf ${NODE_TAR}
sudo cp -R node-${NODE_VERSION}-${NODE_ARCH}/* /usr/local/
rm -rf node-${NODE_VERSION}-${NODE_ARCH} ${NODE_TAR}

echo 'Cloning the latest version of MagicMirror...'
git clone https://github.com/MichMich/MagicMirror.git

echo 'Installing MagicMirror dependencies...'
cd MagicMirror
npm install --arch=armv7l

echo 'Installing Electron for ARMv6 (v25)...'
npm install --arch=armv7l --platform=linux electron@25 --save-dev --unsafe-perm

echo 'Loading default config...'
cp config/config.js.sample config/config.js

echo 'Setting MagicMirror splash screen...'
THEME_DIR="/usr/share/plymouth/themes/MagicMirror"
sudo mkdir -p ${THEME_DIR}
sudo cp ~/MagicMirror/splashscreen/{splash.png,MagicMirror.plymouth,MagicMirror.script} ${THEME_DIR}/
sudo plymouth-set-default-theme -R MagicMirror

echo 'Copying MagicMirror startup scripts...'
cd ~
sudo mv ~/MagicZeroMirror/{mmstart.sh,chromium_start.sh,pm2_MagicMirror.json} ~/
sudo chmod +x ~/mmstart.sh ~/chromium_start.sh ~/pm2_MagicMirror.json

echo 'Installing and setting up PM2 for auto-start...'
sudo npm install -g pm2
pm2 startup systemd -u pi --hp /home/pi
pm2 start ~/pm2_MagicMirror.json
pm2 save

echo 'Installation complete. MagicMirror should start shortly!'
