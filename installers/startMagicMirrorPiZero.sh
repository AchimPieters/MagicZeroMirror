#!/bin/bash
cd ~/Raspberry-MagicMirror;
node serveronly &
sleep 30;
sh ~/Raspberry-MagicMirror/installers/chromium_startPiZero.sh
