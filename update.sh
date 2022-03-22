#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Ubuntu Rolling Remix 

# URLs
# https://ubunturolling.github.io/

#get_latest_release() {
#   curl --silent "https://api.github.com/repos/$1/releases/latest" |
#    grep '"tag_name":' |
#    sed -E 's/.*"([^"]+)".*/\1/'
}

# OS Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print "Unable to detect operating system."
    exit 1
fi

# This script requires Ubuntu Rolling Remix to run since it uses a custom update manager.
if [ "$OS" != "Ubuntu" ]; then
    print "You must be on Ubuntu Rolling Remix to use this script."
    exit 1
fi

# Switch to the user's home directory
cd $HOME

# Update system packages
#install_newpackages() {
#    sudo apt update
#    sudo apt upgrade
#}

install_updatedkernel() {
    cd ~/rhinoupdate/kernel/
    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700_5.17.0-051700.202203202130_all.deb
    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-image-unsigned-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-modules-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
    dpkg -i  *.deb
    apt —fix-broken install
    print "You will need to reboot after the script finishes."
}
