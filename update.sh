#!/bin/bash
# Created by Billy G & MrBeeBenson
# Created for Rhino Rolling Remix

# URLs
# https://rollingrhino.org

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
   if [[ ! -f "$HOME/.rhino/config/5-17-7" ]]; then
    cd ~/rhinoupdate/kernel/
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.7/amd64/linux-headers-5.17.7-051707-generic_5.17.7-051707.202205121146_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.7/amd64/linux-headers-5.17.7-051707_5.17.7-051707.202205121146_all.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.7/amd64/linux-image-unsigned-5.17.7-051707-generic_5.17.7-051707.202205121146_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.7/amd64/linux-modules-5.17.7-051707-generic_5.17.7-051707.202205121146_amd64.deb
    sudo apt install ./*.deb
    : > "$HOME/.rhino/config/5-17-7"
  fi
fi

# If snapd is installed.
[[ -f "$HOME/.rhino/config/snapdpurge" ]] || sudo snap refresh

# If Pacstall has been enabled
if [[ -f "$HOME/.rhino/config/pacstall" ]]; then
# Check to see whether an issue in Curl has been fixed
  if [[ ! -f "$HOME/.rhino/config/curl-fix" ]]; then
    sudo apt remove libcurl4 -y
    sudo apt autoremove -y
    sudo apt install libcurl4 curl -y
    : > "$HOME/.rhino/config/curl-fix"
  fi
  # Install Pacstall
  mkdir -p ~/rhinoupdate/pacstall/
  cd ~/rhinoupdate/pacstall/
  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/1.7.3/pacstall-1.7.3.deb
  sudo apt install ./*.deb
  pacstall -Up
fi

# Perform full system upgrade.
{ sudo apt update; sudo apt dist-upgrade; } 2>&-

# Allow the user to know that the upgrade has completed.
cat << MSG
---------------------------------------------------------------------------------
| The upgrade has been completed. Please reboot your system to see the changes. |
---------------------------------------------------------------------------------
MSG
