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
  echo "alias rhino-config='mkdir ~/.rhino/config/config-script && git clone https://github.com/rollingrhinoremix/rhino-config ~/.rhino/config/config-script/ && python3 ~/.rhino/config/config-script/config.py && rm -rf ~/.rhino/config/config-script'" >> ~/.bashrc
  touch "$HOME/.rhino/updates/configuration"
fi

# Remove SnapD
sudo rm -rf /var/cache/snapd/
sudo apt autoremove --purge snapd gnome-software-plugin-snap
sudo rm -fr ~/snap
sudo apt-mark hold snapd

# Install Flatpak
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak

# Configure FlatHub as the default repoistory for Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install FlatSeal for configuring permissions on FlatHub apps
flatpak install flathub com.github.tchx84.Flatseal

# If the user has selected the option to install the mainline kernel, install it onto the system.
if [ -f "$HOME/.rhino/config/mainline" ]; then
  cd ~/rhinoupdate/kernel/
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.1/amd64/linux-headers-5.17.1-051701-generic_5.17.1-051701.202203280950_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.1/amd64/linux-headers-5.17.1-051701_5.17.1-051701.202203280950_all.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.1/amd64/linux-image-unsigned-5.17.1-051701-generic_5.17.1-051701.202203280950_amd64.deb
  wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17.1/amd64/linux-modules-5.17.1-051701-generic_5.17.1-051701.202203280950_amd64.deb
  sudo dpkg -i  *.deb
  sudo apt --fix-broken install
fi

# Perform full system upgrade
sudo apt update
sudo apt dist-upgrade

# Allow the user to know that the upgrade has completed
echo "---"
echo "System will be rebooted in 1 minute."
echo "---"0
sudo reboot -h +1