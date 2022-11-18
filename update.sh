#!/bin/bash
# Created by Billy G & Chadano
# Maintined by Rolling Rhino Developers
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

# Check to see whether Nala is installed.
if [[ ! -f "$HOME/.rhino/updates/nala" ]]; then
  sudo apt install nala -y
  : > "$HOME/.rhino/updates/nala"
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

# Automatically install the latest Linux kernel onto the system if it has not been installed already. Also ensures that the system is running a pure Linux installation and not RRR installed within WSL.
if [[ ! -f "$HOME/.rhino/config/6-0-8" ]] && [[ ! -f "$HOME/.rhino/config/wsl-yes" ]]; then
    cd ~/rhinoupdate/kernel/
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0.8/amd64/CHECKSUMS &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0.8/amd64/linux-headers-6.0.8-060008-generic_6.0.8-060008.202211101901_amd64.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0.8/amd64/linux-headers-6.0.8-060008_6.0.8-060008.202211101901_all.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0.8/amd64/linux-image-unsigned-6.0.8-060008-generic_6.0.8-060008.202211101901_amd64.deb &
    wget -q --show-progress --progress=bar:force https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0.8/amd64/linux-modules-6.0.8-060008-generic_6.0.8-060008.202211101901_amd64.deb &
    wait
    
    echo "Verifying checksums..."
    if shasum --check --ignore-missing CHECKSUMS; then
      sudo apt install ./*.deb
      : > "$HOME/.rhino/config/6-0-8"
    else
      >&2 echo "Failed to verify checksums of downloaded kernel files!"
      exit 1
    fi
fi

# COMMENTED OUT FOR BUG FIXING

# If the user has enabled a xanmod kernel variant via rhino-config, install it.
#xanmod_variants=$(compgen -G "$HOME/.rhino/config/xanmod-*")
#if $xanmod_variants; then
#    echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
#    wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
#    sudo apt update
#    
#    for variant in $xanmod_variants; do
#    	case $variant in
#    		stable)
#    			sudo apt install linux-xanmod
#    		;;
#    		realtime)
#    			sudo apt install linux-xanmod-rt
#    		;;
#    		realtime_edge)
#    			sudo apt install linux-xanmod-rt-edge
#    		;;
#    		tasktype)
#    			sudo apt install linux-xanmod-tt
#    		;;
#    		*)
#    			sudo apt install "linux-$variant"
#    		;;
#    	esac
#    done
#fi

# If the user has enabled the liq kernel via rhino-config, install it.
if [[ -f "$HOME/.rhino/config/liquorix" ]]; then
   sudo add-apt-repository ppa:damentz/liquorix && sudo apt-get update
   sudo apt install linux-image-liquorix-amd64 linux-headers-liquorix-amd64
fi

if [[ -f "$HOME/.rhino/config/libre" ]]; then
   echo "deb mirror://linux-libre.fsfla.org/pub/linux-libre/freesh/mirrors.txt freesh main " | sudo tee --append /etc/apt/sources.list
   wget -O - https://jxself.org/gpg.asc | sudo apt-key add -
   sudo apt update
   sudo apt install linux-libre
fi

# If snapd is installed, update apps.
type -P snap &>/dev/null && sudo snap refresh

# If flatpak is installed, update apps.
type -P flatpak &> /dev/null && flatpak update

# If Pacstall has been enabled
#if [[ -f "$HOME/.rhino/config/pacstall" ]]; then
  # Install Pacstall
#  mkdir -p ~/rhinoupdate/pacstall/
#  cd ~/rhinoupdate/pacstall/
#  wget -q --show-progress --progress=bar:force https://github.com/pacstall/pacstall/releases/download/2.0.1/pacstall-2.0.1.deb
#  sudo apt install ./*.deb
#  if [[ ! $EUID -eq 0 ]]; then
#    pacstall -Up
#  fi
# fi

# Perform full system upgrade.
sudo nala upgrade || { sudo apt-get update && sudo apt-get upgrade; }

# Install/Fix system files such as /etc/os-release
cd ~
mkdir ~/rhinoupdate/system-files/
git clone https://github.com/rollingrhinoremix/assets ~/rhinoupdate/system-files/
sudo mv ~/rhinoupdate/system-files/os-release /usr/lib/

# Allow the user to know that the upgrade has completed.
echo "---
The upgrade has been completed. Please reboot your system to see the changes.
---"
