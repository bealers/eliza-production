#!/bin/bash
set -e

# Create CLI helper script
cat > /usr/local/bin/eliza-cli <<'EOL'
#!/bin/bash

# Stop if running as root
#if [ "$(id -u)" = "0" ]; then
   #echo "This script must not be run as root"
   #exit 1
#fi

# Stop the service first (we have NOPASSWD sudo for this)
sudo systemctl stop eliza

# Switch to eliza and start CLI (no password needed as we're sudoing)
cd /opt/eliza/agent
sudo -u eliza bash -c 'source ~/.nvm/nvm.sh && HTTP_PORT=3001 pnpm start --characters="../characters/default.character.json" --interface=direct'

# Restart service on exit
sudo systemctl start eliza
EOL

chmod +x /usr/local/bin/eliza-cli
