#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Rhino Rolling Remix 

# URLs
# https://rollingrhinoremix.github.io/

set -e

# Check to see whether the "configuration update", released in 2022.04.14 has been applied.
if [[ ! -f "$HOME/.rhino/updates/configuration" ]]; then
  mkdir -p ~/.rhino/{config,updates}
  echo "alias rhino-config='mkdir ~/.rhino/config/config-script && git clone https://github.com/rollingrhinoremix/rhino-config ~/.rhino/config/config-script/ && python3 ~/.rhino/config/config-script/config.py && rm -rf ~/.rhino/config/config-script'" >> ~/.bashrc
  : > "$HOME/.rhino/updates/configuration"
fi

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [[ -f "$HOME/.rhino/config/mainline" ]]; then
  cd ~/rhinoupdate/kernel/
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.3/amd64/linux-headers-5.17.3-051703-generic_5.17.3-051703.202204131853_amd64.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.3/amd64/linux-headers-5.17.3-051703_5.17.3-051703.202204131853_all.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.3/amd64/linux-image-unsigned-5.17.3-051703-generic_5.17.3-051703.202204131853_amd64.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.3/amd64/linux-modules-5.17.3-051703-generic_5.17.3-051703.202204131853_amd64.deb
  sudo apt install ./*.deb
fi

# If snapd is installed.
if [[ ! -f "$HOME/.rhino/config/snapdpurge" ]]; then
  sudo snap refresh
fi


# If Pacstall has been enabled
if [[ -f "$HOME/.rhino/config/pacstall" ]]; then
  mkdir -p ~/rhinoupdate/pacstall/
  cd ~/rhinoupdate/pacstall/
  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/1.7.3/pacstall-1.7.3.deb
  sudo apt install ./*.deb
  pacstall -Up
fi

# Perform full system upgrade.
{ sudo apt update; sudo apt dist-upgrade; }

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"
