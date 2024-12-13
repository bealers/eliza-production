#!/bin/bash

echo "=== Cleanup and Optimization ==="

# Clear package manager cache
apt-get clean
apt-get autoremove -y

# Final system checks
display_status "Checking system status..."
systemctl status eliza
ufw status verbose

echo "=== Installation Complete ==="
echo "Don't forget to:"
echo "1. Configure your .env file in $INSTALL_DIR particularly the API keys"
echo "2. Set up SSL certificates if needed"

echo "3. Control the service with:"
echo "   sudo systemctl start eliza   - Start the service"
echo "   sudo systemctl stop eliza    - Stop the service"
echo "   sudo systemctl restart eliza - Restart the service"
echo "   sudo systemctl status eliza  - Check service status"

echo "4. View logs with:"
echo "   sudo journalctl -u eliza -f    - Follow logs in real-time"

echo "5. Character file is symlinked to:"
echo "   $INSTALL_DIR/characters/default.character.json"
