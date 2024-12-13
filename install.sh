#!/bin/bash

set -e
set -o pipefail
umask 022

# Output handling to STDOUT and $LOG_FILE
output() {
    echo ">>> $1"
    echo ">>> $1" >> "$LOG_FILE"
}

# Variables
NVM_VERSION=v0.39.1
NODE_VERSION=23.3.0

# The maintainer of this server (you?)
USER=bealers

# The service user that the agent will run as
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
export NVM_VERSION NODE_VERSION USER SERVICE_USER AGENT_REPO INSTALL_DIR LOG_DIR LOG_FILE
export -f output

# Run provisioning scripts in order
for script in "$SCRIPT_DIR"/[0-9][0-9]-*.sh; do
    if [ -f "$script" ]; then
        output "Running $(basename "$script")..."
        bash "$script" 2>&1 | tee -a "$LOG_FILE"
        output "Completed $(basename "$script")"
    fi
done

output "Installation completed successfully!"
