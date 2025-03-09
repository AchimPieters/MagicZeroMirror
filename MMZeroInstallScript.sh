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

# MMZeroInstallScript.sh
# Installs MagicMirror, PM2, Midori, unclutter, etc. on a Pi Zero
# running Raspberry Pi OS (Bookworm).

# Update and upgrade system
sudo apt-get update
sudo apt-get -y upgrade

# Install key packages
sudo apt-get install -y \
  git \
  nodejs \
  npm \
  pm2 \
  midori \
  unclutter \
  x11-xserver-utils

# Clone MagicMirror repository if not already cloned
cd /home/pi
git clone https://github.com/MichMich/MagicMirror
cd /home/pi/MagicMirror
npm install

# Copy pm2_MagicMirror.json to home directory (adjust paths if needed)
# e.g. if you already downloaded or placed the JSON somewhere:
# cp /path/to/pm2_MagicMirror.json /home/pi/
# Make sure it is in /home/pi/pm2_MagicMirror.json for the next steps

# Ensure your scripts are executable
chmod +x /home/pi/mmstart.sh
chmod +x /home/pi/midori_start.sh

# Set up PM2 to run MagicMirror on boot
pm2 startup systemd -u pi --hp /home/pi
pm2 start /home/pi/pm2_MagicMirror.json
pm2 save

echo "Installation complete. Reboot to start MagicMirror via PM2 and Midori."
