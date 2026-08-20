#!/usr/bin/env bash
set -euo pipefail

GIT_USER="nezutero"
NIXOS_GIT="https://codeberg.org/${GIT_USER}/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
NVIM_DIR="$HOME/nvim"
BACKUP_ETC_NIXOS="/etc/nixos.bak"

# 1. clone nixos config (HTTPS, nothing needed)
if [ -d "$NIXOS_DIR" ]; then
  echo "Skipping clone: $NIXOS_DIR exists"
else
  git clone "$NIXOS_GIT" "$NIXOS_DIR"
fi

# backup /etc/nixos and symlink to ~/nixos
if [ -L /etc/nixos ]; then
  echo "/etc/nixos already a symlink"
elif [ -e /etc/nixos ]; then
  sudo mv /etc/nixos "$BACKUP_ETC_NIXOS"
  sudo ln -s "$NIXOS_DIR" /etc/nixos
else
  sudo ln -s "$NIXOS_DIR" /etc/nixos
fi

# 2. rebuild (may generate SSH key, clone dotfiles/nvim via HTTPS, setup home-manager)
echo "Running: sudo nixos-rebuild switch"
sudo nixos-rebuild switch

# print SSH public key if it exists
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo
  echo "=== SSH public key ==="
  cat "$HOME/.ssh/id_ed25519.pub"
  echo "======================"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo
  echo "=== SSH public key ==="
  cat "$HOME/.ssh/id_rsa.pub"
  echo "======================"
else
  echo "No SSH public key found at ~/.ssh/*.pub"
fi

# 3. pause for user to add key to GitHub
read -p "Add the SSH key to GitHub, then press Enter to continue (Ctrl+C to abort)..."

# 4. switch remotes to SSH for pushing
set -x
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" remote set-url origin git@github.com:${GIT_USER}/dotfiles.git
fi
if [ -d "$NVIM_DIR/.git" ]; then
  git -C "$NVIM_DIR" remote set-url origin git@github.com:${GIT_USER}/nvim.git
fi
if [ -d "$NIXOS_DIR/.git" ]; then
  git -C "$NIXOS_DIR" remote set-url origin git@github.com:${GIT_USER}/nixos.git
fi
set +x

echo "Done."
