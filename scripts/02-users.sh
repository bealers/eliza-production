#!/bin/bash
set -e

# Maintenance user
if ! id "$USER" &>/dev/null; then
    useradd -m -s /bin/bash "$USER"
fi

# SSH setup
mkdir -p /home/$USER/.ssh
cp /root/.ssh/authorized_keys /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

# Sudo access
echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

# Service user
useradd -r -s /bin/bash -d "$INSTALL_DIR" -m $SERVICE_USER
chown -R $SERVICE_USER:$SERVICE_USER "${INSTALL_DIR}"
chmod 750 "${INSTALL_DIR}"
# TODO: Opsec hardening
# WARNING: This will very likely break default Digital Ocean access methods
#
# echo "PermitRootLogin no" >> /etc/ssh/sshd_config
# echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# systemctl restart sshd
# passwd -l root  # Lock root account
