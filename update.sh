#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Ubuntu Rolling Remix 

# URLs
# https://ubunturolling.github.io/

#get_latest_release() {
#   curl --silent "https://api.github.com/repos/$1/releases/latest" |
#    grep '"tag_name":' |
#    sed -E 's/.*"([^"]+)".*/\1/'
#}

#Check if Rhino update is configured. 
if [ ! -f "$HOME/.rhino/updates/configuration" ]; then
 # Code will go here 
  touch "$HOME/.rhino/updates/configuration"
fi

# Perform system upgrade
sudo apt update
sudo apt dist-upgrade
# Allow the user to know that the upgrade has completed
echo "---"
echo "You will need to reboot after the script finishes."
echo "---"
