# Run Eliza on a bare bones VM

Disclaimer: This is a super alpha, not ready for actual production.

## Prerequisites

- Digital Ocean droplet with the latest Ubuntu LTS (24.04)
- The droplet is provisioned with an ssh key that you have control over

## Quick Start

```bash
# become root
ssh root@your-droplet-ip -i ~/.ssh/your-private-key

# clone the repo
git clone https://github.com/bealers/eliza-remote.git
cd eliza-remote && chmod +x install.sh

# run the install script
./install.sh
```

## Current Status & Known Issues

### Working
- User setup (maintenance and service users)
- NVM and Node installation
- Directory structure
- Basic security hardening
- Log rotation setup

### TODO
- [ ] Debug systemd service startup issues
- [ ] Test character switching via symlinks
- [ ] Verify all environment variables are properly set
- [ ] Add proper error handling for failed service starts
- [ ] Document manual startup procedure for debugging
- [ ] SSL support
- [ ] Multiple characters support

## Post-Installation

1. Configure `.env` file:
```bash
sudo vi /opt/eliza/.env
```

2. Start the service:
```bash
sudo systemctl start eliza
```

## Maintenance

### Updates
```bash
# Switch to service user
sudo -i -u eliza

# Update application
cd /opt/eliza
git pull
git checkout $(git describe --tags --abbrev=0)
pnpm install

# Exit back to maintenance user
exit

# Restart service
sudo systemctl restart eliza
```

### Switching Characters
```bash
sudo -i -u eliza
cd /opt/eliza
ln -sf characters/trump.character.json characters/default.character.json
exit
sudo systemctl restart eliza
```

### Logs
- Application: `/var/log/eliza/eliza.log`
- Errors: `/var/log/eliza/eliza-error.log`
- Installation: `/var/log/eliza/install.log`

### Service Control
```bash
sudo systemctl {start|stop|restart|status} eliza
sudo journalctl -u eliza -f
```

### Debugging
```bash
# Check service status
sudo systemctl status eliza

# View logs
sudo journalctl -u eliza -f

# Try manual startup as service user
sudo -i -u eliza
cd /opt/eliza
source ~/.nvm/nvm.sh
pnpm start --characters="characters/default.character.json"
```

## Security

- Dedicated service user
- Systemd security policies
- Restricted file permissions
- UFW firewall configuration

### Optional Hardening
The installation includes commented instructions for:
- Disabling root SSH access
- Disabling password authentication
- Locking root account

**Note:** Enabling these will break default Digital Ocean root access methods.
See `scripts/02-users.sh` for details.

## Disclaimer

Yes, I could have used Docker.

## License

MIT License

## Credit
H/T to [HowieDuhzi](https://github.com/HowieDuhzit) for the WSL install script that inspired this fork.
