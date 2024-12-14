#!/bin/bash

echo "Installing application dependencies..."

apt-get -qq -y install python3 python3-pip ffmpeg nodejs npm

# Setup application directory
echo "Setting up application directory..."
mkdir -p "${INSTALL_DIR}"
chown -R "${SERVICE_USER}:${SERVICE_USER}" "${INSTALL_DIR}"

# Create a temporary script to run as eliza
cat > /tmp/eliza-setup.sh <<EOF
#!/bin/bash
set -e

cd "${INSTALL_DIR}"
echo "Working directory: \$(pwd)"

# Preserve .bashrc and .nvm if they exist
mv .bashrc /tmp/.bashrc.backup || true
mv .nvm /tmp/.nvm.backup || true

# Clean directory
rm -rf * .[!.]* ..?*

echo "Cloning repository..."
git clone ${AGENT_REPO} .
git checkout \$(git describe --tags --abbrev=0)

# Restore preserved files
mv /tmp/.bashrc.backup .bashrc || true
mv /tmp/.nvm.backup .nvm || true

# Add NVM config to .bashrc for persistent setup
echo "
# NVM Setup
export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
export PATH=\"\$HOME/node_modules/.bin:\$PATH\"
" >> .bashrc

echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Set nvm up in current shell to use it immediately
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"

nvm install v${NODE_VERSION}
nvm alias default v${NODE_VERSION}
nvm use default

npm install -g pnpm
pnpm install

test -f .env.example && cp .env.example .env

# Setup default character via symlink
if [ -f "${INSTALL_DIR}/characters/eternalai.character.json" ]; then
    ln -sf "${INSTALL_DIR}/characters/eternalai.character.json" "${INSTALL_DIR}/characters/default.character.json"
else
    echo "Warning: Default character file not found!"
    ls -la "${INSTALL_DIR}/characters/"
fi
mkdir -p "${INSTALL_DIR}/data/memory/default"
chmod 750 "${INSTALL_DIR}/data"
EOF

# Make it executable and run as eliza
chmod +x /tmp/eliza-setup.sh
chown $SERVICE_USER:$SERVICE_USER /tmp/eliza-setup.sh
sudo -u $SERVICE_USER /tmp/eliza-setup.sh
#rm /tmp/eliza-setup.sh

# systemd
cat > /etc/systemd/system/eliza.service <<EOL
[Unit]
Description=Eliza AI Chat Agent
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$INSTALL_DIR
Environment=NODE_ENV=production
Environment=HOME=$INSTALL_DIR

# Reduced security restrictions to fix mounting issues
NoNewPrivileges=true
ProtectSystem=full
PrivateTmp=true

ExecStart=/bin/bash -c 'source ~/.nvm/nvm.sh && pnpm start --characters="characters/default.character.json"'
Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/eliza.log
StandardError=append:$LOG_DIR/eliza-error.log

[Install]
WantedBy=multi-user.target
EOL

# Setup log rotation
cat > /etc/logrotate.d/eliza <<EOL
$LOG_DIR/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 640 $SERVICE_USER $SERVICE_USER
}
EOL

# Enable and start service
systemctl daemon-reload
systemctl enable eliza
systemctl start eliza

echo "Eliza service installed and started"
