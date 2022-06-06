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
wget -q --show-progress --progress=bar:force https://github.com/rollingrhinoremix/rhino-config/releases/latest/download/rhino-config
chmod +x rhino-config
sudo mv rhino-config /usr/bin
rm -rf ~/rhino-config

# Install the latest rhino-deinst utility
mkdir ~/rhinoupdate/rhino-deinst
cd ~/rhinoupdate/rhino-deinst
wget -q --show-progress --progress=bar:force https://github.com/rollingrhinoremix/rhino-deinst/releases/latest/download/rhino-deinst
chmod +x rhino-deinst
sudo mv rhino-deinst /usr/bin

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [[ -f "$HOME/.rhino/config/mainline" ]] && [[ ! -f "$HOME/.rhino/config/5-18-2" ]]; then
    cd ~/rhinoupdate/kernel/
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.2/amd64/CHECKSUMS
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.2/amd64/linux-headers-5.18.2-051802-generic_5.18.2-051802.202206060740_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.2/amd64/linux-headers-5.18.2-051802_5.18.2-051802.202206060740_all.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.2/amd64/linux-image-unsigned-5.18.2-051802-generic_5.18.2-051802.202206060740_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.2/amd64/linux-modules-5.18.2-051802-generic_5.18.2-051802.202206060740_amd64.deb
    
    echo "Verifying checksums..."
    if shasum --check --ignore-missing CHECKSUMS; then
      sudo apt install ./*.deb
      : > "$HOME/.rhino/config/5-18-0"
    else
      >&2 echo "Failed to verify checksums of downloaded kernel files!"
      exit 1
    fi
fi

# If snapd is installed.
if [[ -f "/usr/bin/snap" ]]; then
  sudo snap refresh
fi

# If flatpak is installed
if [[ -f "/usr/bin/flatpak" ]]; then
  flatpak update
fi

# If Pacstall has been enabled
if [[ -f "$HOME/.rhino/config/pacstall" ]]; then
  # Install Pacstall
  mkdir -p ~/rhinoupdate/pacstall/
  cd ~/rhinoupdate/pacstall/
  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/1.7.3/pacstall-1.7.3.deb
  sudo apt install ./*.deb
  if [[ ! $EUID -eq 0 ]]; then
    pacstall -Up
  fi
fi

# Perform full system upgrade.
{ sudo apt update 2> /dev/null; sudo apt dist-upgrade 2> /dev/null; }

# Install/Fix system files such as /etc/os-release
cd ~
mkdir ~/rhinoupdate/system-files/
git clone https://github.com/rollingrhinoremix/assets ~/rhinoupdate/system-files/
sudo rm -rf /etc/os-release
sudo mv ~/rhinoupdate/system-files/os-release /etc/

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"
