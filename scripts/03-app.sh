#!/bin/bash

echo "Installing application dependencies..."

apt-get -q -y install python3 python3-pip ffmpeg > /dev/null

# Switch to service user for installation
su - "${SERVICE_USER}" <<'EOF'
set -e  # Exit on any error

echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Ensure NVM is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "Installing Node.js..."
nvm install v${NODE_VERSION}
nvm alias default v${NODE_VERSION}
nvm use default

echo "Installing pnpm..."
npm install -g pnpm

echo "Cloning repository..."
cd $HOME
rm -rf * .[!.]* ..?*  # Clean directory except . and ..
git clone ${AGENT_REPO} .
git checkout $(git describe --tags --abbrev=0)

echo "Installing dependencies..."
pnpm install

echo "Setting up environment..."
test -f .env.example && cp .env.example .env
test -f characters/eliza.character.json && cp characters/eliza.character.json characters/default.character.json
mkdir -p data/memory/default

# Verify installation
echo "Verifying installation..."
which node
which pnpm
node -v
pnpm -v
EOF

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

# Security enhancements
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=read-only
PrivateTmp=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictAddressFamilies=AF_INET AF_INET6
RestrictNamespaces=true
ReadWritePaths=$LOG_DIR $INSTALL_DIR/data

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
