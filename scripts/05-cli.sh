#!/bin/bash
set -e

# Create CLI helper script
cat > /usr/local/bin/eliza-cli <<'EOL'
#!/bin/bash

# Stop if running as root
if [ "$(id -u)" = "0" ]; then
   echo "This script must not be run as root"
   exit 1
fi

# Switch to eliza and start CLI
sudo -i -u eliza bash <<EOF
cd /opt/eliza
source ~/.nvm/nvm.sh

# Stop the service first to free up port
sudo systemctl stop eliza

# Start in CLI mode with direct interface
cd agent
HTTP_PORT=3001 pnpm start --characters="../characters/default.character.json" --interface=direct
EOF
EOL

chmod +x /usr/local/bin/eliza-cli
