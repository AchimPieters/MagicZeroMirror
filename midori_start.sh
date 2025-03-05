#!/bin/bash
set -e

echo "Starting unclutter to hide mouse cursor..."
unclutter &

echo "Disabling power management and screen blanking..."
xset -dpms   # Disable power management
xset s off   # Disable screen saver
xset s noblank  # Prevent screen blanking

echo "Launching Midori in kiosk mode..."
midori -e Fullscreen -a http://localhost:8080 &

echo "MagicMirror UI should now be visible."
