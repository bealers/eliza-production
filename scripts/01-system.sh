#!/bin/bash

apt-get update
apt-get upgrade -y

apt-get install -y \
    vim \
    curl \
    git \
    unzip \
    zip \
    ntp \
    ufw

# Configure firewall
ufw default deny incoming
ufw default allow outgoing

# Core system access
ufw allow 22/tcp  # SSH

#ufw allow 3000/tcp  # API port
#TODO, On by default? make a setting/UI flag?

ufw allow 80/tcp   # HTTP (for redirect)
ufw allow 443/tcp  # HTTPS/Platform APIs

ufw --force enable

# Locale setup (so your agent's environment matches yours, adjust to suit)
# TODO: make a setting/UI flag for this?
timedatectl set-timezone Europe/London
locale-gen en_GB.UTF-8
update-locale LANG=en_GB.UTF-8

display_status "System setup completed"
