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

# Clean install workspace
rm -rf node_modules
rm -rf agent/node_modules
rm -rf packages/*/node_modules

# Install and build workspace
pnpm install --force
pnpm build

# Link workspace packages
cd packages/adapter-postgres
pnpm link --global
cd ../../agent
pnpm link --global @ai16z/adapter-postgres
cd ..

# Setup environment
cp -v .env.example .env

# Configure ports and interfaces
# note: external access to port 3000 is currently blocked by the firewall
sed -i '1i\
# Interface Configuration\
HTTP_ENABLED=true\
HTTP_PORT=3000        # Main service API\
CLI_HTTP_PORT=3001    # CLI debug port\
\
' .env

cd characters
ln -svf eternalai.character.json default.character.json
cd ..
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
Environment=HTTP_PORT=3000

# Add debug output
StandardOutput=append:$LOG_DIR/eliza.log
StandardError=append:$LOG_DIR/eliza-error.log

ExecStart=/bin/bash -c '\
    source ~/.nvm/nvm.sh && \
    echo "Node version: \$(node -v)" && \
    echo "PWD: \$(pwd)" && \
    echo "Starting Eliza API on port 3000..." && \
    pnpm start --characters="characters/default.character.json"'

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# Enable and start
systemctl daemon-reload
systemctl enable eliza
systemctl start eliza
