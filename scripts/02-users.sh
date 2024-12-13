#!/bin/bash

# Maintenance user (you)

if ! id "$USER" &>/dev/null; then
    useradd -m -s /bin/bash "$USER"
fi

## ssh (using your ssh key that DO added for you)
mkdir -p /home/$USER/.ssh
cp /root/.ssh/authorized_keys /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

## sudo for you
echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

## bash tweaks
cat > /home/$USER/.bashrc << 'EOL'
export EDITOR=vim # sue me
alias ls='ls --color=auto -Fhla --group-directories-first'
EOL
chown $USER:$USER /home/$USER/.bashrc

# Service user
mkdir -p "${INSTALL_DIR}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" -m $SERVICE_USER
fi

# Setup service user's home
cat > "${INSTALL_DIR}/.bashrc" << 'EOL'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Load NVM
export PATH="$HOME/node_modules/.bin:$PATH"
EOL
chown -R $SERVICE_USER:$SERVICE_USER "${INSTALL_DIR}"
chmod 750 "${INSTALL_DIR}"

# TODO: Opsec hardening
# WARNING: This will very likely break default Digital Ocean access methods
#
# echo "PermitRootLogin no" >> /etc/ssh/sshd_config
# echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# systemctl restart sshd
# passwd -l root  # Lock root account
