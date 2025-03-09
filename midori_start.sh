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

# midori_start.sh
# Launches the Midori browser in fullscreen mode
# to display MagicMirror served on localhost.

# Disable screen blanking and screen saver
xset -dpms
xset s off
xset s noblank

# Hide the mouse pointer after a few seconds (if desired)
# Uncomment if you have unclutter installed
# unclutter &

# Wait briefly to ensure the MagicMirror server is running
sleep 10

# Launch Midori in fullscreen (kiosk-like) mode, pointing to localhost
midori -e Fullscreen -a http://localhost:8080

/home/pi/.config/lxsession/LXDE-pi/autostart

@/home/pi/midori_start.sh
