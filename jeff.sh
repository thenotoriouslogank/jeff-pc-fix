#!/bin/bash

firefoxBak() {
    cd ~
    path=$(pwd)
    sudo cp -r ${path}/.mozilla firefox.bak
    if [ -d ${path}/firefox.bak ]; then
        echo "Backup successfully created."
    else
        echo "Backup failed. . ."
    fi
}

firefoxApt() {
    # Remove snap Firefox package since it's fucking broken
    sudo snap remove firefox
    # Add the official Mozilla PPA to apt list
    sudo add-apt-repository ppa:mozillateam/ppa
    # Change Firefox package priority to prefer PPA/deb/apt version
    echo '
    Package: *
    Pin: release o=LP-PPA-mozillateam
    Pin-Priority: 1001
    ' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    # Ensure Firefox updates when sudo apt update is run
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
    # Install Firefox via apt
    sudo apt install firefox -y
    sudo apt update && sudo apt full-upgrade -y
}

# Backup firefox data
if [ -d ~/.mozilla/firefox ]; then
    echo "Backing up current firefox data. . ."
    firefoxBak
    firefoxApt
else
    echo "Unable to locate Firefox data for backup."
    echo ""
    read -p "Continue?" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Continuing. . ."
        firefoxApt
    else
        echo "Quitting. . ."
        exit 1
    fi
fi
