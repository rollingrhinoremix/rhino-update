#!/bin/bash
# Created Billy G & MrBeeBenson
# Created for Ubuntu Rolling Remix 

# URLs
# https://ubunturolling.github.io/

#get_latest_release() {
#   curl --silent "https://api.github.com/repos/$1/releases/latest" |
#    grep '"tag_name":' |
#    sed -E 's/.*"([^"]+)".*/\1/'
#}

# Update system packages
#install_newpackages() {
#    sudo apt update
#    sudo apt upgrade
#}

install_updatedkernel() {
#    cd ~/rhinoupdate/kernel/
#    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
#    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-headers-5.17.0-051700_5.17.0-051700.202203202130_all.deb
#    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-image-unsigned-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
#    wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.17/amd64/linux-modules-5.17.0-051700-generic_5.17.0-051700.202203202130_amd64.deb
#    dpkg -i  *.deb
#    sudo apt --fix-broken install
    sudo apt update
    sudo apt upgrade
    sudo apt dist-upgrade
    print "You will need to reboot after the script finishes."
}
