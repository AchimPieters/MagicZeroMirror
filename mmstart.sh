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

set -e  # Exit immediately if a command fails

echo "Starting MagicMirror..."
cd ~/MagicMirror || { echo "MagicMirror directory not found!"; exit 1; }

DISPLAY=:0 npm start &  # Start MagicMirror in the background
sleep 10  # Give it some time to initialize

echo "Starting MagicMirror server in headless mode..."
node serveronly &

echo "Waiting for MagicMirror to fully initialize..."
sleep 30  # Adjust sleep time if necessary

echo "Launching Chromium..."
sh ~/chromium_start.sh || { echo "chromium_start.sh not found!"; exit 1; }

echo "Setup complete. MagicMirror should now be running!"
