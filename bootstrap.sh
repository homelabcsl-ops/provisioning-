#!/usr/bin/env bash
set -e

echo "🚀 Starting DevOps Idempotent Pave Sequence..."

# Safe execution directory to bypass read-only mounts
cd /tmp || exit

# 1. Architecture Detection
ARCH=$(uname -m)
echo "🔍 Detected Architecture: $ARCH"

# 2. Core System Dependencies (via native DNF)
echo "📦 Provisioning core Red Hat system packages..."
sudo dnf install -y epel-release
# FIXED: Added util-linux-user to provide the 'chsh' command
sudo dnf install -y git zsh make gcc unzip gettext curl wget tar util-linux-user readline-devel nodejs

# 3. Zoxide (Elite Static Provisioning)
if ! command -v zoxide &>/dev/null; then
  echo "🦘 Provisioning Zoxide static binary for $ARCH..."
  if [ "$ARCH" = "aarch64" ]; then
    ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-aarch64-unknown-linux-musl.tar.gz"
  else
    ZOXIDE_URL="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-x86_64-unknown-linux-musl.tar.gz"
  fi

  # Extract *only* the zoxide binary directly into /usr/local/bin
  curl -sL "$ZOXIDE_URL" | sudo tar -C /usr/local/bin -xzf - zoxide
  sudo chmod +x /usr/local/bin/zoxide
else
  echo "✅ Zoxide is already installed."
fi

# 4. FZF
if [ ! -d "$HOME/.fzf" ]; then
  echo "🔍 Installing FZF static binary..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-update-rc
else
  echo "✅ FZF is already installed."
fi

# 5. FZF Git Bindings
if [ ! -d "$HOME/fzf-git.sh" ]; then
  echo "🤝 Cloning fzf-git.sh bindings..."
  git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh
else
  echo "✅ fzf-git.sh is already present."
fi

# 6. Starship
if ! command -v starship &>/dev/null; then
  echo "⭐ Installing Starship..."
  curl -sS https://starship.rs/install.sh | sudo sh -s -- -y
else
  echo "✅ Starship is already installed."
fi

# ==============================================================================
# 7. NEOVIM ENGINE (PINNED: v0.11.5)
# Architectural Parity: Mirrors host macOS environment exactly.
# ==============================================================================
echo "🛠️ Provisioning Neovim engine (v0.11.5) for $ARCH..."

# Check if the correct version is already installed
if command -v nvim &>/dev/null && nvim --version | head -n 1 | grep -q "v0.11.5"; then
  echo "✅ Neovim v0.11.5 is already installed."
else
  echo "🔄 Updating/Downgrading Neovim to strictly pinned v0.11.5..."

  # 1. Purge any existing floating/nightly builds
  sudo rm -rf /opt/nvim /usr/local/bin/nvim

  # 2. Set the correct URL based on architecture
  if [ "$ARCH" = "aarch64" ]; then
    NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-arm64.tar.gz"
  else
    NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux64.tar.gz"
  fi

  # 3. Pull the exact locked release binary for Linux
  curl -LO "$NVIM_URL"

  # 4. Extract to the system /opt directory
  # Note: The extracted folder name depends on arch, so we handle it gracefully
  if [ "$ARCH" = "aarch64" ]; then
    sudo tar -C /opt -xzf nvim-linux-arm64.tar.gz
    sudo mv /opt/nvim-linux-arm64 /opt/nvim
  else
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    sudo mv /opt/nvim-linux64 /opt/nvim
  fi

  # 5. Create the global symlink
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

  # 6. Clean up the artifact
  rm nvim-linux*.tar.gz
fi
# ==============================================================================

# 8. Default Shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  echo "🐚 Changing default shell to Zsh..."
  sudo chsh -s /usr/bin/zsh $USER
fi

echo "🎉 Provisioning Complete! The environment is p
