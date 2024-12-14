#!/bin/bash
set -e

echo "=== Cleanup and Optimization ==="

# Clear package manager cache
apt-get -qq clean > /dev/null
apt-get -qq -y autoremove > /dev/null

# Final system checks
echo "Checking final system status..."
systemctl status eliza
ufw status verbose

echo "=== Installation Complete ==="
echo "Eliza is now installed with:"
echo "1. API Service (port 3000)"
echo "   - Status: sudo systemctl status eliza"
echo "   - Logs: sudo journalctl -u eliza -f"
echo ""
echo "2. CLI Interface"
echo "   - Run: eliza-cli"
echo "   - Uses port 3001"
echo ""
echo "3. Configuration"
echo "   - Main config: $INSTALL_DIR/.env"
echo "   - Character: $INSTALL_DIR/characters/default.character.json"
echo "   - Logs: $LOG_DIR/"
