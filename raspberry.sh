#!/usr/bin/env bash

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
# Based on a work at https://github.com/ac2799/MagicMirrorPi0Installer/. By Andrew Chu

echo -e "\e[0m"
echo 'MagicMirror Raspberry Pi Zero Installation'
echo -e "\e[0m"

# Define the tested version of Node.js.
NODE_TESTED="v5.1.0"

# Determine which Pi is running.
ARM=$(uname -m)

# Check the Raspberry Pi version.
if [ "$ARM" = "armv6l" ]; then
	echo -e "\e[91mIf you are running a Pi Zero, installation will continue, but you will have to run in server only mode."
elif [ "$ARM" != "armv7l" ]; then
	echo -e "\e[91mSorry, your Raspberry Pi is not supported."
	echo -e "\e[91mPlease run MagicMirror on a Raspberry Pi 0, 2 or 3."
	exit;
fi

# Define helper methods.
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function command_exists () { type "$1" &> /dev/null ;}

# Update before first apt-get
echo -e "\e[96mUpdating packages ...\e[90m"
sudo apt-get update || echo -e "\e[91mUpdate failed, carrying on installation ...\e[90m"
sudo apt-get upgrade && apt-get upgrade --fix-missing || echo -e "\e[91mUpdate failed, carrying on installation ...\e[90m"

# Installing helper tools
echo -e "\e[96mInstalling helper tools ...\e[90m"
sudo apt-get --assume-yes install curl wget git build-essential unzip || exit

# Check if we need to install or upgrade Node.js.
echo -e "\e[96mCheck current Node installation ...\e[0m"
NODE_INSTALL=false
if command_exists node; then
	echo -e "\e[0mNode currently installed. Checking version number.";
	NODE_CURRENT=$(node -v)
	echo -e "\e[0mMinimum Node version: \e[1m$NODE_TESTED\e[0m"
	echo -e "\e[0mInstalled Node version: \e[1m$NODE_CURRENT\e[0m"
	if version_gt $NODE_TESTED $NODE_CURRENT; then
		echo -e "\e[96mNode should be upgraded.\e[0m"
		NODE_INSTALL=true

		# Check if a node process is currenlty running.
		# If so abort installation.
		if pgrep "node" > /dev/null; then
			echo -e "\e[91mA Node process is currently running. Can't upgrade."
			echo "Please quit all Node processes and restart the installer."
			exit;
		fi
	else
		echo -e "\e[92mNo Node.js upgrade necessary.\e[0m"
	fi
else
	echo -e "\e[93mNode.js is not installed.\e[0m";
	NODE_INSTALL=true
fi

# Install or upgrade node if necessary.
if $NODE_INSTALL; then

	echo -e "\e[96mInstalling Node.js ...\e[90m"

	# Fetch the latest version of Node.js from the selected branch
	# The NODE_STABLE_BRANCH variable will need to be manually adjusted when a new branch is released. (e.g. 7.x)
	# Only tested (stable) versions are recommended as newer versions could break MagicMirror.

	NODE_STABLE_BRANCH="9.x"
	if [ "$ARM" = "armv7l" ]; then
		curl -sL https://deb.nodesource.com/setup_$NODE_STABLE_BRANCH | sudo -E bash -
		sudo apt-get install -y nodejs
		echo -e "\e[92mNode.js installation Done!\e[0m"
	elif [ "$ARM" = "armv6l" ]; then
		echo 'Downloading node v11.6.0'
		curl -o node-v11.6.0-linux-armv6l.tar.gz  https://nodejs.org/dist/v11.6.0/node-v11.6.0-linux-armv6l.tar.gz; #Most up to date recent version
		echo 'Extracting node v11.6.0'
		tar -xzf node-v11.6.0-linux-armv6l.tar.gz; # extract files
		echo 'Extracting node and npm'
		cd node-v11.6.0-linux-armv6l/;
		sudo cp -R * /usr/local/;
		cd ~;
	fi
fi

# Install git and unclutter if on a Pi Zero
if [ "$ARM" = "armv6l" ]; then
	sudo apt install git; sudo apt install unclutter;
fi

# Install MagicMirror
cd ~
if [ -d "$HOME/MagicMirror" ] ; then
	echo -e "\e[93mIt seems like MagicMirror is already installed."
	echo -e "To prevent overwriting, the installer will be aborted."
	echo -e "Please rename the \e[1m~/MagicMirror\e[0m\e[93m folder and try again.\e[0m"
	echo ""
	echo -e "If you want to upgrade your installation run \e[1m\e[97mgit pull\e[0m from the ~/MagicMirror directory."
	echo ""
	exit;
fi

echo -e "\e[96mCloning MagicMirror ...\e[90m"
if git clone --depth=1 https://github.com/MichMich/MagicMirror.git; then
	echo -e "\e[92mCloning MagicMirror Done!\e[0m"
else
	echo -e "\e[91mUnable to clone MagicMirror."
	exit;
fi

cd ~/MagicMirror  || exit
echo -e "\e[96mInstalling dependencies ...\e[90m"
if [ "$ARM" = "armv6l" ]; then
	if npx npmc@latest install; then
		echo -e "\e[91mErrors while installing dependencies! (source command: npmc@latest install)"
	fi
	if npm install acorn@latest; then
		echo -e "\e[91mErrors while installing dependencies! (source command: npm install acorn@latest)"
	fi
	if npm install stylelint@latest; then
		echo -e "\e[91mErrors while installing dependencies! (source command: pm install stylelint@latest)"
	fi
	if npm audit fix; then
		echo -e "\e[91mVulnerabilities may remain!"
	fi
elif [ "$ARM" = "armv7l" ]; then
	if npm install; then
		echo -e "\e[92mDependencies installation Done!\e[0m"
	else
		echo -e "\e[91mUnable to install dependencies!"
		exit;
	fi
fi

# Use sample config for start MagicMirror
cp config/config.js.sample config/config.js

# Check if plymouth is installed (default with PIXEL desktop environment), then install custom splashscreen.
echo -e "\e[96mCheck plymouth installation ...\e[0m"
if command_exists plymouth; then
	THEME_DIR="/usr/share/plymouth/themes"
	echo -e "\e[90mSplashscreen: Checking themes directory.\e[0m"
	if [ -d $THEME_DIR ]; then
		echo -e "\e[90mSplashscreen: Create theme directory if not exists.\e[0m"
		if [ ! -d $THEME_DIR/MagicMirror ]; then
			sudo mkdir $THEME_DIR/MagicMirror
		fi

		if sudo cp ~/MagicMirror/splashscreen/splash.png $THEME_DIR/MagicMirror/splash.png && sudo cp ~/MagicMirror/splashscreen/MagicMirror.plymouth $THEME_DIR/MagicMirror/MagicMirror.plymouth && sudo cp ~/MagicMirror/splashscreen/MagicMirror.script $THEME_DIR/MagicMirror/MagicMirror.script; then
			echo -e "\e[90mSplashscreen: Theme copied successfully.\e[0m"
			if sudo plymouth-set-default-theme -R MagicMirror; then
				echo -e "\e[92mSplashscreen: Changed theme to MagicMirror successfully.\e[0m"
			else
				echo -e "\e[91mSplashscreen: Couldn't change theme to MagicMirror!\e[0m"
			fi
		else
			echo -e "\e[91mSplashscreen: Copying theme failed!\e[0m"
		fi
	else
		echo -e "\e[91mSplashscreen: Themes folder doesn't exist!\e[0m"
	fi
else
	echo -e "\e[93mplymouth is not installed.\e[0m";
fi

# Use pm2 control like a service MagicMirror
read -p "Do you want use pm2 for auto starting of your MagicMirror (y/N)?" choice
if [[ $choice =~ ^[Yy]$ ]]; then
	sudo npm install -g pm2
	if [ "$ARM" = "armv6l" ]; then
		mkdir ~/MagicMirror/PiZero;
sudo mv ~/Raspberry-MagicMirror/startMagicMirrorPiZero.sh ~/MagicMirror/PiZero/startMagicMirrorPiZero.sh;
sudo mv ~/Raspberry-MagicMirror/pm2_MagicMirrorPiZero.json ~/MagicMirror/PiZero/pm2_MagicMirrorPiZero.json;
sudo mv ~/Raspberry-MagicMirror/chromium_startPiZero.sh ~/MagicMirror/PiZero/chromium_startPiZero.sh;
sudo chmod a+x ~/MagicMirror/PiZero/startMagicMirrorPiZero.sh;
sudo chmod a+x ~/MagicMirror/PiZero/pm2_MagicMirrorPiZero.json;
sudo chmod a+x ~/MagicMirror/PiZero/chromium_startPiZero.sh;
		sudo su -c "env PATH=$PATH:/usr/bin pm2 startup systemd -u pi --hp $HOME"
    pm2 start ~/MagicMirror/installers/pm2_MagicMirrorPiZero.json
    pm2 save
		echo " "
		echo -e "\e[92mWe're ready! Restart your Pi Zero to start your MagicMirror. \e[0m"
	elif [ "$ARM" = "armv7l" ]; then
    sudo su -c "env PATH=$PATH:/usr/bin pm2 startup systemd -u pi --hp $HOME"
    pm2 start ~/MagicMirror/installers/pm2_MagicMirror.json
    pm2 save
		echo " "
		echo -e "\e[92mWe're ready! Run \e[1m\e[97mDISPLAY=:0 npm start\e[0m\e[92m from the ~/MagicMirror directory to start your MagicMirror.\e[0m"
	fi
fi
echo " "
echo " "
