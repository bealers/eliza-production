#!/bin/bash
set -e

# Run as service user
sudo -u $SERVICE_USER bash <<EOF
cd $INSTALL_DIR

# Clone repo
git clone ${AGENT_REPO} .
git checkout \$(git describe --tags --abbrev=0)

# Install NVM and Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
export NVM_DIR="\$HOME/.nvm"
. "\$NVM_DIR/nvm.sh"
nvm install v${NODE_VERSION}
nvm use v${NODE_VERSION}

# Install dependencies
npm install -g pnpm
pnpm install

# Setup environment
cp -v .env.example .env
ln -svf characters/eternalai.character.json characters/default.character.json
mkdir -p data/memory/default
chmod 750 data
EOF

# Setup service
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

ExecStart=/bin/bash -c 'source ~/.nvm/nvm.sh && pnpm start --characters="characters/default.character.json"'
Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/eliza.log
StandardError=append:$LOG_DIR/eliza-error.log

[Install]
WantedBy=multi-user.target
EOL

# Enable and start
systemctl daemon-reload
systemctl enable eliza
systemctl start eliza
