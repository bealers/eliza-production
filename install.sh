#!/bin/bash

set -e
set -o pipefail
umask 022

# Prevent interactive prompts during installation
export DEBIAN_FRONTEND=noninteractive

# Variables
NVM_VERSION=v0.39.1
NODE_VERSION=23.3.0

# Server admin (gets root via sudo)
USER=hiro-protagonist

# The user the agent runs as
SERVICE_USER=eliza

AGENT_REPO=https://github.com/ai16z/eliza.git

INSTALL_DIR=/opt/eliza
SCRIPT_DIR=./scripts
LOG_DIR=/var/log/eliza
LOG_FILE=$LOG_DIR/install.log

# Create install log file
mkdir -p $LOG_DIR
touch $LOG_FILE
chmod 640 $LOG_FILE

# Export variables for subscripts
# TODO, yuck this is ugly
export NVM_VERSION NODE_VERSION USER SERVICE_USER AGENT_REPO INSTALL_DIR LOG_DIR LOG_FILE

# Run provisioning scripts in order
for script in "$SCRIPT_DIR"/[0-9][0-9]-*.sh; do
    if [ -f "$script" ]; then
        echo "Running $(basename "$script")..."
        bash "$script" 2>&1 | tee -a "$LOG_FILE"
        echo "Completed $(basename "$script")"
    fi
done

echo "Installation completed successfully!"
