#!/bin/bash
cd ~/MagicMirror;
node serveronly &
sleep 30;
xinit /home/pi/chromium_start.sh
