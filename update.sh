#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Rhino Rolling Remix 

# URLs
# https://rollingrhinoremix.github.io/

# Perform full system upgrade
sudo apt update
sudo apt dist-upgrade

# Allow the user to know that the upgrade has completed
echo "---"
echo "You will need to reboot after the script finishes."
echo "---"
