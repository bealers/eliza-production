#!/bin/bash

# Maintenance user (you)

if ! id "$USER" &>/dev/null; then
    useradd -m -s /bin/bash "$USER"
fi

## ssh (using the ssh key that DO handily added for you)
mkdir -p /home/$USER/.ssh
cp /root/.ssh/authorized_keys /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

## sudo for you
echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

cat > /home/$USER/.bashrc << 'EOL'
#!/bin/bash
export EDITOR=vim # sue me
alias ls='ls --color=auto -Fhla --group-directories-first'
EOL
chown $USER:$USER /home/$USER/.bashrc

# Service user
mkdir -p "${INSTALL_DIR}"
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" -m $SERVICE_USER
fi

cat > "${INSTALL_DIR}/.bashrc" << 'EOL'
#!/bin/bash
export EDITOR=vim
alias ls='ls --color=auto -Fhla --group-directories-first'
EOL

# Set permissions
chown -R $SERVICE_USER:$SERVICE_USER "${INSTALL_DIR}"
chmod 750 "${INSTALL_DIR}"

# TODO: Opsec hardening
# WARNING: This will very likely break default Digital Ocean access methods
#
# echo "PermitRootLogin no" >> /etc/ssh/sshd_config
# echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
# systemctl restart sshd
# passwd -l root  # Lock root account
