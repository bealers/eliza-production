#!/bin/bash
set -e

# Clean and prepare install directory
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${LOG_DIR}"

# Update system packages quietly
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install \
    vim \
    curl \
    git \
    unzip \
    zip \
    ntp \
    ufw \
    python3 \
    python3-pip \
    ffmpeg

# Configure firewall
ufw default deny incoming
ufw default allow outgoing

#ufw allow 3000/tcp  # API port?
#TODO, On by default? make a setting/UI flag?

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable

# Locale setup (so your agent's environment matches yours; adjust to suit)
# TODO: make a setting/UI flag for this?
timedatectl set-timezone Europe/London
locale-gen en_GB.UTF-8 > /dev/null
update-locale LANG=en_GB.UTF-8

echo "System setup completed"
