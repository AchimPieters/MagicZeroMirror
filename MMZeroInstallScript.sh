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

echo 'Updating Raspberry Pi...'
sudo apt-get update -y && sudo apt-get upgrade -y --fix-missing

echo 'Installing dependencies...'
sudo apt install -y npm git xinit xorg matchbox unclutter midori

echo 'Cloning MagicMirror...'
git clone https://github.com/MichMich/MagicMirror.git ~/MagicMirror || echo "MagicMirror already cloned."

cd ~/MagicMirror

echo 'Installing MagicMirror dependencies...'
npm install --arch=armv7l

# Copy default config if missing
if [ ! -f ~/MagicMirror/config/config.js ]; then
  cp ~/MagicMirror/config/config.js.sample ~/MagicMirror/config/config.js
fi

echo 'Copying MagicMirror startup scripts...'
cd ~

echo 'Creating midori_start.sh...'
echo "#!/bin/bash
midori -e Fullscreen -a http://localhost:8080 &" > ~/midori_start.sh
chmod +x ~/midori_start.sh

echo 'Setting up MagicMirror to start on boot...'
echo "@/home/pi/mmstart.sh" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
chmod +x ~/mmstart.sh

echo 'Setup complete! Reboot your Raspberry Pi to start MagicMirror.'
