# Run Eliza on a bare bones VM

Disclaimer: This is a super alpha, not ready for actual production.

## Quick Start

```bash
git clone https://github.com/bealers/eliza-remote.git
cd eliza-remote && chmod +x install.sh
./install.sh
```

## Prerequisites (currently tested on)

- Digital Ocean Droplet with the latest Ubuntu LTS
- The droplet is provisioned with an ssh key that you have control over

## Features

- [x] Systemd service management
- [x] Log rotation
- [x] Basic security hardening
- [ ] SSL
- [ ] Multiple characters support


## Installation Options

### Standard Install
```bash
./install.sh
```

### Custom Character Install TODO - DOES NOT WORK YET
```bash
export ELIZA_CHARACTER=/path/to/character.json
./install.sh
```

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
sudo systemctl stop eliza
cd /opt/eliza
sudo -u eliza git pull
sudo -u eliza git checkout $(git describe --tags --abbrev=0)
sudo -u eliza pnpm install
sudo systemctl start eliza
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

## Troubleshooting

1. Check service status:
```bash
sudo systemctl status eliza
```

2. View logs:
```bash
sudo journalctl -u eliza -f
```

3. Verify permissions:
```bash
ls -la /opt/eliza
ls -la /var/log/eliza
```

## Development

### TODO
- [ ] Configuration UI
- [ ] Backup/restore functionality
- [ ] Monitoring integration
- [ ] SSL/TLS automation
- [ ] Multi-character management UI

## License

MIT License

## Credit
H/T to [HowieDuhzi](https://github.com/HowieDuhzit) for the WSL install script that inspired this fork.
