# MagicMirror² 3.1.9 Installer for the Raspberry Pi Zero W

This installer allows users of the Raspberry Pi Zero W to also access the popular MagicMirror² personal assistant project.

## Installation

### Raspberry Pi Zero W

Install the most recent available Raspbian Image (This is tested on Raspbian Jessie and Raspbian Stretch). You do not need the 'recommended software', but you do need the 'desktop'. Therefore do not use the 'Lite' version.

Set up your Internet connection. You may also want to set up SSH and VNC at this time.

For More Information Visit http://www.studiopieters.nl

## Note: Work In progress!




[![GitHub license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://raw.githubusercontent.com/hyperion-project/hyperion.ng/master/LICENSE) [![Donate](https://img.shields.io/badge/donate-PayPal-blue.svg)](https://paypal.me/AJFPieters)


### MagicMirror² Installation

Clone this project into your home directory (It should come down into the folder ~/Raspberry-MagicMirror)

```
git clone https://github.com/AchimPieters/Raspberry-MagicMirror.git
```

Run the command

```
sudo chmod a+x ~/Raspberry-MagicMirror/raspberry.sh && bash ~/Raspberry-MagicMirror/raspberry.sh
```

This will make the shell script executable, and if that is successful, it will also run the script.

This can take up to an hour, depending on how many updates and upgrades need to be made to your Raspbian version. There is minimal interaction required, except to press enter a couple of times to agree to updates outside of the repository (e.g. updates to the raspbian operating system).
