# Raspberry-MagicMirror
Raspberry – MagicMirror²

For More Information Visit http://www.studiopieters.nl

## Installation

### Raspberry Pi Zero

Install the most recent available Raspbian Image (This is tested on Raspbian Jessie and Raspbian Stretch). You do not need the 'recommended software', but you do need the 'desktop'. Therefore do not use the 'Lite' version.

Set up your Internet connection. You may also want to set up SSH and VNC at this time.

### MagicMirror² Installation 

Clone this project into your home directory (It should come down into the folder ~/Raspberry-MagicMirror)

```
git clone --recursive https://github.com/AchimPieters/Raspberry-MagicMirror.git
```

Run the command

```
sudo chmod a+x ~/Raspberry-MagicMirror/RaspberryPi0.sh && sh ~/Raspberry-MagicMirror/RaspberryPi0.sh
```

This will make the shell script executable, and if that is successful, it will also run the script.

This can take up to an hour, depending on how many updates and upgrades need to be made to your Raspbian version. There is minimal interaction required, except to press enter a couple of times to agree to updates outside of the repository (e.g. updates to the Raspbian operating system).


## Note: Work In progress!

- [ ] Debugging the Main Code
- [ ] ..
- [ ] ..
- [ ] ..
- [ ] ..



[![GitHub license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://raw.githubusercontent.com/hyperion-project/hyperion.ng/master/LICENSE)
[![GitHub license](https://img.shields.io/github/v/release/achimpieters/ESP8266-HomeKit-Blinds)](https://img.shields.io/github/v/release/achimpieters/ESP8266-HomeKit-Blinds)
[![Donate](https://img.shields.io/badge/donate-PayPal-blue.svg)](https://paypal.me/AJFPieters)

###### This Project is build upon MagicMirror² from Michael Teeuw, creator of the MagicMirror² project. The installation script is base upon MagicMirrorPi0Installer from AC2799.
