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

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [[ -f "/usr/share/rhino/config/mainline" ]] && [[ ! -f "/usr/share/rhino/config/5-18-0" ]]; then
    cd /usr/share//rhinoupdate/kernel/
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18/amd64/CHECKSUMS
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18/amd64/linux-headers-5.18.0-051800-generic_5.18.0-051800.202205222030_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18/amd64/linux-headers-5.18.0-051800_5.18.0-051800.202205222030_all.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18/amd64/linux-image-unsigned-5.18.0-051800-generic_5.18.0-051800.202205222030_amd64.deb
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.18/amd64/linux-modules-5.18.0-051800-generic_5.18.0-051800.202205222030_amd64.deb
    
    echo "Verifying checksums..."
    if shasum --check --ignore-missing CHECKSUMS; then
      sudo apt install ./*.deb
      : > "/usr/share/rhino/config/5-18-0"
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
{ sudo apt update 2> /dev/null; sudo apt dist-upgrade 2> /dev/null; }

# Install/Fix system files such as /etc/os-release
cd /usr/share/rhino
mkdir /usr/share/rhino/rhinoupdate/system-files/
git clone https://github.com/rollingrhinoremix/assets /usr/share/rhino/rhinoupdate/system-files/
sudo rm -rf /etc/os-release
sudo mv /usr/share/rhino/rhinoupdate/system-files/os-release /etc/
chmod -R 775 /usr/share/rhino # In case this was ran with root - for regular users

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"
