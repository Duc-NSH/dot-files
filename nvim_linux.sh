#!/bin/bash

# Neovim User-Specific Installation & Uninstallation Script with Shell Detection

# Variables
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
INSTALL_DIR="$HOME/.local/bin"
NVIM_BIN="$INSTALL_DIR/nvim"
CONFIG_FILE=""

# Detect Current Shell
CURRENT_SHELL=$(ps -p $$ -o comm=)
echo "🛠️ Detected Shell: $CURRENT_SHELL"

# Set the appropriate shell configuration file
case "$CURRENT_SHELL" in
bash)
  CONFIG_FILE="$HOME/.bashrc"
  ;;
zsh)
  CONFIG_FILE="$HOME/.zshrc"
  ;;
*)
  echo "⚠️ Unsupported shell: $CURRENT_SHELL"
  echo "Please manually add or remove ~/.local/bin to your PATH."
  exit 1
  ;;
esac

# Add PATH to shell configuration
add_path_to_shell_config() {
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$CONFIG_FILE"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$CONFIG_FILE"
    echo "✅ Added ~/.local/bin to PATH in $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    echo "ℹ️ ~/.local/bin is already in PATH in $CONFIG_FILE"
  fi
}

# Remove PATH from shell configuration
remove_path_from_shell_config() {
  if grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$CONFIG_FILE"; then
    sed -i '/export PATH="\$HOME\/.local\/bin:\$PATH"/d' "$CONFIG_FILE"
    echo "✅ Removed ~/.local/bin from PATH in $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    echo "ℹ️ ~/.local/bin was not found in PATH in $CONFIG_FILE"
  fi
}

# Install Neovim
install_nvim() {
  echo "🚀 Starting Neovim Installation..."

  # Ensure the installation directory exists
  mkdir -p "$INSTALL_DIR"

  # Download the Neovim AppImage
  echo "⬇️ Downloading Neovim AppImage..."
  curl -L "$NVIM_URL" -o "$NVIM_BIN"

  # Make it executable
  chmod u+x "$NVIM_BIN"

  # Verify Installation
  if [ -x "$NVIM_BIN" ]; then
    echo "✅ Neovim installed successfully at $NVIM_BIN"
  else
    echo "❌ Error: Neovim installation failed!"
    exit 1
  fi

  # Add ~/.local/bin to PATH
  add_path_to_shell_config

  # Verify Neovim
  echo "📝 Installed Neovim Version:"
  "$NVIM_BIN" --version

  echo "🎯 Installation Complete! Run 'nvim' to start Neovim."
}

# Uninstall Neovim
uninstall_nvim() {
  echo "🗑️ Starting Neovim Uninstallation..."

  # Remove Neovim binary
  if [ -f "$NVIM_BIN" ]; then
    rm -f "$NVIM_BIN"
    echo "✅ Removed Neovim binary from $NVIM_BIN"
  else
    echo "ℹ️ Neovim binary not found in $NVIM_BIN"
  fi

  # Remove ~/.local/bin from PATH
  remove_path_from_shell_config

  # Optional: Remove Neovim config and cache
  echo "🧹 Do you want to remove Neovim configuration and cache? (y/n)"
  read -r RESPONSE
  if [[ "$RESPONSE" == "y" ]]; then
    rm -rf "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.cache/nvim"
    echo "✅ Removed Neovim configuration and cache directories"
  else
    echo "ℹ️ Neovim configuration and cache were not removed"
  fi

  echo "🎯 Uninstallation Complete!"
}

# Display Help
show_help() {
  echo "🔧 Neovim Installer Script"
  echo ""
  echo "Usage:"
  echo "  $0 install    Install Neovim in ~/.local/bin"
  echo "  $0 uninstall  Uninstall Neovim from ~/.local/bin"
  echo "  $0 help       Display this help message"
}

# Main Script Logic
case "$1" in
install)
  install_nvim
  ;;
uninstall)
  uninstall_nvim
  ;;
help)
  show_help
  ;;
*)
  echo "⚠️ Invalid option!"
  show_help
  exit 1
  ;;
esac
