#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Rhino Rolling Remix 

# URLs
# https://rollingrhinoremix.github.io/

# Check to see whether the "configuration update", released in 2022.04.14 has been applied.
if [ ! -f "$HOME/.rhino/updates/configuration" ]; then
  mkdir ~/.rhino
  mkdir ~/.rhino/config
  mkdir ~/.rhino/updates
  echo "alias rhino-config='mkdir ~/.rhino/config/config-script && git clone https://github.com/rollingrhinoremix/rhino-config ~/.rhino/config/config-script/ && python3 ~/.rhino/config/config-script/config.py && rm -rf ~/.rhino/config/config-script'" >> .bashrc
  touch "$HOME/.rhino/updates/configuration"
fi

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [ -f "$HOME/.rhino/config/mainline" ]; then
  cd ~/rhinoupdate/kernel/
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700_5.17.0-051700.202203202130_all.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-image-unsigned-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-modules-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
  sudo dpkg -i  *.deb
  sudo apt --fix-broken install
fi

# Perform full system upgrade
sudo apt update
sudo apt dist-upgrade

# Allow the user to know that the upgrade has completed
echo "---"
echo "You will need to reboot after the script finishes."
echo "---"
