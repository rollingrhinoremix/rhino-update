#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Rhino Rolling Remix 

# URLs
# https://rollingrhinoremix.github.io/

set -e

# Check to see whether the "configuration update", released in 2022.04.19 has been applied.
if [[ ! -f "$HOME/.rhino/updates/configuration" ]]; then
  mkdir -p ~/.rhino/{config,updates}
  echo "alias rhino-config='mkdir ~/.rhino/config/config-script && git clone https://github.com/rollingrhinoremix/rhino-config ~/.rhino/config/config-script/ && python3 ~/.rhino/config/config-script/config.py && rm -rf ~/.rhino/config/config-script'" >> ~/.bashrc
  : > "$HOME/.rhino/updates/configuration"
fi

# Check to see whether the rhino-config v2 update has been applied, which converts Rhino into a command-line utility.
if [[ ! -f "$HOME/.rhino/updates/config-v2" ]]; then
  mkdir ~/rhinoupdate/distro
  git clone https://github.com/rollingrhinoremix/distro ~/rhinoupdate/distro
  mv ~/rhinoupdate/distro/.{bashrc,bash_aliases} ~
  : > "$HOME/.rhino/updates/config-v2"
fi

# Install latest rhino-config utility
mkdir ~/rhino-config
cd ~/rhino-config
wget -q --show-progress --progress=bar:force https://github.com/rollingrhinoremix/rhino-config/releases/download/v2.0.1/rhino-config
chmod +x rhino-config
sudo mv rhino-config /usr/bin
rm -rf ~/rhino-config

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [[ -f "$HOME/.rhino/config/mainline" ]]; then
  cd ~/rhinoupdate/kernel/
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.5/amd64/linux-headers-5.17.5-051705-generic_5.17.5-051705.202204271406_amd64.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.5/amd64/linux-headers-5.17.5-051705_5.17.5-051705.202204271406_all.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.5/amd64/linux-image-unsigned-5.17.5-051705-generic_5.17.5-051705.202204271406_amd64.deb
  wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.5/amd64/linux-modules-5.17.5-051705-generic_5.17.5-051705.202204271406_amd64.deb
  sudo dpkg -i *.deb
  sudo apt --fix-broken install -y
fi

# If snapd is installed.
if [[ ! -f "$HOME/.rhino/config/snapdpurge" ]]; then
  sudo snap refresh
fi


# If Pacstall has been enabled
if [[ -f "$HOME/.rhino/config/pacstall" ]]; then
  #sudo bash -c "$(curl -fsSL https://git.io/JsADh || wget -q https://git.io/JsADh -O -)"
  sudo apt install curl -y
  mkdir -p ~/rhinoupdate/pacstall/
  cd ~/rhinoupdate/pacstall/
  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/1.7.3/pacstall-1.7.3.deb
  sudo apt --fix-broken install ./pacstall-1.7.3.deb
  pacstall -Up
fi

# Perform full system upgrade.
{ sudo apt update 2> /dev/null; sudo apt dist-upgrade 2> /dev/null; }

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"