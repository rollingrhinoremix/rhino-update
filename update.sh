#!/bin/bash
# Created by Billy G & MrBeeBenson
# Created for Rhino Rolling Remix 

# URLs
# https://rollingrhino.org

set -e

# Check whether there is a newer version of this script
cd /usr/rhino/rhino-updater
if /usr/bin/git pull; then
    chmod +x /usr/rhino/rhino-updater/update.sh
    exec /usr/bin/rhino-update
    exit $?
fi

# Check to see whether the "configuration update", released in 2022.04.19 has been applied.
if [[ ! -f "/usr/share/rhino/updates/configuration" ]]; then
  mkdir -p /usr/share/rhino/{config,updates}
  echo "alias rhino-config='mkdir /usr/share/rhino/config/config-script && git clone https://github.com/rollingrhinoremix/rhino-config /usr/share/rhino/config/config-script/ && python3 /usr/share/rhino/config/config-script/config.py && rm -rf /usr/share/rhino/config/config-script'" >> ~/.bashrc
  : > "/usr/share/rhino/updates/configuration"
fi

# Check to see whether the rhino-config v2 update has been applied, which converts Rhino into a command-line utility.
if [[ ! -f "/usr/share/rhino/updates/config-v2" ]]; then
  mkdir /usr/share/rhino/rhinoupdate/distro
  git clone https://github.com/rollingrhinoremix/distro /usr/share/rhino/rhinoupdate/distro
  mv /usr/share/rhino/rhinoupdate/distro/.{bashrc,bash_aliases} ~
  : > "/usr/share/rhino/updates/config-v2"
fi

# Check to see whether Nala is installed.
if [[ ! -f "$HOME/.rhino/updates/nala" ]]; then
  sudo apt install nala -y
  : > "$HOME/.rhino/updates/nala"
fi

# Install latest rhino-config utility
mkdir /usr/share/rhino/rhino-config
cd /usr/share/rhino/rhino-config
wget -q --show-progress --progress=bar:force https://github.com/rollingrhinoremix/rhino-config/releases/latest/download/rhino-config
chmod +x rhino-config
sudo mv rhino-config /usr/bin
rm -rf /usr/share/rhino/rhino-config

# Install the latest rhino-deinst utility
mkdir /usr/share/rhino/rhinoupdate/rhino-deinst
cd /usr/share/rhino/rhinoupdate/rhino-deinst
wget -q --show-progress --progress=bar:force https://github.com/rollingrhinoremix/rhino-deinst/releases/latest/download/rhino-deinst
chmod +x rhino-deinst
sudo mv rhino-deinst /usr/bin

# Automatically install the latest Linux kernel onto the system if it has not been installed already.
if [[ ! -f "/usr/share/.rhino/config/5-18-3" ]]; then
    cd ~/rhinoupdate/kernel/
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.3/amd64/CHECKSUMS &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.3/amd64/linux-headers-5.18.3-051803-generic_5.18.3-051803.202206090934_amd64.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.3/amd64/linux-headers-5.18.3-051803_5.18.3-051803.202206090934_all.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.3/amd64/linux-image-unsigned-5.18.3-051803-generic_5.18.3-051803.202206090934_amd64.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18.3/amd64/linux-modules-5.18.3-051803-generic_5.18.3-051803.202206090934_amd64.deb &
    wait
    
    echo "Verifying checksums..."
    if shasum --check --ignore-missing CHECKSUMS; then
      sudo apt install ./*.deb
      : > "/usr/share/.rhino/config/5-18-3"
    else
      >&2 echo "Failed to verify checksums of downloaded kernel files!"
      exit 1
    fi
fi

# If the user has enabled the xanmod kernel via rhino-config, install it.
if [[ -f "$HOME/.rhino/config/xanmod" ]]; then
    echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
    wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
    sudo apt update && sudo apt install linux-xanmod
fi

# If the user has enabled the liq kernel via rhino-config, install it.
if [[ -f "$HOME/.rhino/config/liquorix" ]]; then
   sudo add-apt-repository ppa:damentz/liquorix && sudo apt-get update
   sudo apt install linux-image-liquorix-amd64 linux-headers-liquorix-amd64
fi

# If snapd is installed, update apps.
if [[ -f "/usr/bin/snap" ]]; then
  sudo snap refresh
fi

# If flatpak is installed, update apps.
if [[ -f "/usr/bin/flatpak" ]]; then
  flatpak update
fi

# If Pacstall has been enabled
if [[ -f "/usr/share/rhino/config/pacstall" ]]; then
  # Install Pacstall
  mkdir -p /usr/share/rhino/rhinoupdate/pacstall/
  cd /usr/share/rhino/rhinoupdate/pacstall/
  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/1.7.3/pacstall-1.7.3.deb
  sudo apt install ./*.deb
  if [[ ! $EUID -eq 0 ]]; then
    pacstall -Up
  fi
fi

# Perform full system upgrade.
sudo nala upgrade

# Install/Fix system files such as /etc/os-release
cd /usr/share/rhino
mkdir /usr/share/rhino/rhinoupdate/system-files/
git clone https://github.com/rollingrhinoremix/assets /usr/share/rhino/rhinoupdate/system-files/
sudo mv /usr/share/rhino/rhinoupdate/system-files/os-release /usr/lib/

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"
