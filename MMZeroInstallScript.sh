#!/bin/bash
#
# Copyright 2020 Achim Pieters | StudioPieters®
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
echo 'Updating Pi'
sudo apt-get update;

echo 'Upgrading Pi'
sudo apt-get upgrade;
sudo apt-get upgrade --fix-missing;

echo 'Downloading node v10.16.0'
sudo wget https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-armv6l.tar.xz;

echo 'Extracting node v11.6.0'
tar xvf node-v10.16.0-linux-armv6l.tar.xz;
cd node-v10.16.0-linux-armv6l;
sudo cp -R * /usr/local/;

echo 'Installing Magic Mirror Dependencies'
cd ~;
sudo apt install npm -Y;
sudo apt install git;

echo 'Cloning the latest version of Magic Mirror2'
git clone https://github.com/MichMich/MagicMirror;

echo 'Installing Magic Mirror Dependencies'
cd MagicMirror;
npm install --arch=armv7l;
sudo apt install chromium-browser -Y;
sudo apt-get install xinit -Y;
sudo apt install xorg -Y;
sudo apt install matchbox -Y;
sudo apt install unclutter -Y;

echo 'Loading default config'
cp config/config.js.sample config/config.js;

echo 'Set the splash screen to be magic mirror'
THEME_DIR="/usr/share/plymouth/themes"
sudo mkdir $THEME_DIR/MagicMirror;
sudo cp ~/MagicMirror/splashscreen/splash.png $THEME_DIR/MagicMirror/splash.png && sudo cp ~/MagicMirror/splashscreen/MagicMirror.plymouth $THEME_DIR/MagicMirror/MagicMirror.plymouth && sudo cp ~/MagicMirror/splashscreen/MagicMirror.script $THEME_DIR/MagicMirror/MagicMirror.script;
sudo plymouth-set-default-theme -R MagicMirror;

echo 'Copy Magic Mirror2 startup scripts'
cd ~;
sudo mv ~/Raspberry-MagicMirror/mmstart.sh ~/home/pi/mmstart.sh;
sudo mv ~/Raspberry-MagicMirror/chromium_start.sh ~/home/pi/chromium_start.sh;
sudo mv ~/Raspberry-MagicMirror/pm2_MagicMirror.json ~/home/pi/pm2_MagicMirror.json;
sudo chmod a+x mmstart.sh;
sudo chmod a+x chromium_start.sh;
sudo chmod a+x pm2_MagicMirror.json;

echo 'Use pm2 control like a service MagicMirror'
sudo npm install -g pm2;
sudo env PATH=$PATH:/usr/local/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
pm2 start ~/home/pi/pm2_MagicMirror.json;
pm2 save;
echo 'Magic Mirror should begin shortly'
