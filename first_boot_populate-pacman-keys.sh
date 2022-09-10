#!/bin/bash
# Populate pacman keys and install python for ansible

# scp to rpi with alarm user
#   scp alarm@rpi4:first_boot_populate-pacman-keys.sh
# enter alarm user's default password: alarm
# ssh rpi4
# su -c ./first_boot_populate-pacman-keys.sh

set -o errexit

main() {

    checkNetwork
    populatePacmanKeys
}

checkNetwork() {

    echo "Checking internet connectivity..."
    if ping -c 4 www.google.com; then
        echo "Connected to the internet"
    else
        echo "Test failed. Check your network or dns settings."
        return 1
    fi
}

populatePacmanKeys() {

    pacman-key --init
    pacman-key --populate archlinuxarm
    # Update local cache
    pacman -Syy
    pacman -Fy
    # Needed for ansible
    pacman -S --needed --noconfirm python
}

main