#!/bin/bash

# Copyright 2019 Achim Pieters | StudioPieters®
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Based on a work at https://github.com/ac2799/MagicMirrorPi0Installer By Andrew Chu

echo 'Updating Pi'
sudo apt-get update;
echo 'Upgrading Pi'
sudo apt-get upgrade;
sudo apt-get upgrade --fix-missing;

echo 'Downloading node v11.6.0'
curl -o node-v11.6.0-linux-armv6l.tar.gz  https://nodejs.org/dist/v11.6.0/node-v11.6.0-linux-armv6l.tar.gz; #Most up to date recent version
echo 'Extracting node v11.6.0'
tar -xzf node-v11.6.0-linux-armv6l.tar.gz; # extract files
echo 'Extracting node and npm'

cd node-v11.6.0-linux-armv6l/;
sudo cp -R * /usr/local/;
cd ~;
sudo apt install git; sudo apt install unclutter;
echo 'Cloning Magic Mirror'

git clone https://github.com/MichMich/MagicMirror;
cd MagicMirror;
echo 'Installing Magic Mirror Dependencies'
npx npmc@latest install; npm install acorn@latest; npm install stylelint@latest; npm audit fix;
echo 'Loading default config'

# Use sample config for start MagicMirror
cp config/config.js.sample config/config.js;

#Set the splash screen to be magic mirror
THEME_DIR="/usr/share/plymouth/themes"
sudo mkdir $THEME_DIR/MagicMirror
sudo cp ~/MagicMirror/splashscreen/splash.png $THEME_DIR/MagicMirror/splash.png && sudo cp ~/MagicMirror/splashscreen/MagicMirror.plymouth $THEME_DIR/MagicMirror/MagicMirror.plymouth && sudo cp ~/MagicMirror/splashscreen/MagicMirror.script $THEME_DIR/MagicMirror/MagicMirror.script;
sudo plymouth-set-default-theme -R MagicMirror;
mkdir ~/MagicMirror/PiZero;
sudo mv ~/MagicMirrorPi0Installer/startMagicMirrorPi0.sh ~/MagicMirror/PiZero/startMagicMirrorPi0.sh;
sudo mv ~/MagicMirrorPi0Installer/pm2_MagicMirrorPi0.json ~/MagicMirror/PiZero/pm2_MagicMirrorPi0.json;
sudo mv ~/MagicMirrorPi0Installer/chromium_startPi0.sh ~/MagicMirror/PiZero/chromium_startPi0.sh;
sudo chmod a+x ~/MagicMirror/PiZero/startMagicMirrorPi0.sh;
sudo chmod a+x ~/MagicMirror/PiZero/pm2_MagicMirrorPi0.json;
sudo chmod a+x ~/MagicMirror/PiZero/chromium_startPi0.sh;

# Use pm2 control like a service MagicMirror
sudo npm install -g pm2;
sudo su -c "env PATH=$PATH:/usr/bin pm2 startup systemd -u pi --hp $HOME";
pm2 start ~/MagicMirror/PiZero/pm2_MagicMirrorPi0.json;
pm2 save;
echo 'Magic Mirror should begin shortly'
