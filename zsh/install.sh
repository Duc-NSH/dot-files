#!/bin/bash

# =============================================================================
# Complete Zsh + Oh-My-Zsh + Plugins Setup Script
# =============================================================================
# Description: Sets up zsh with oh-my-zsh, powerlevel10k, and essential plugins
# Author: DucNSH
# Usage: ./install.sh [--append-only]
# Flags: --append-only  Skip installations, only append custom configurations
#
# Expected workflow:
# 1. Clone dotfiles repo to ~/dot-files/ (must include zsh/.zshrc)
# 2. Run this script to install zsh + oh-my-zsh + plugins + append custom config
# 3. Configure powerlevel10k when prompted
# =============================================================================

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration paths
DOTFILES_DIR="$HOME/dot-files"
ZSH_CONFIG_APPEND="$DOTFILES_DIR/zsh/.zshrc"
ZSHRC="$HOME/.zshrc"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
  echo -e "${BOLD}${BLUE}"
  echo "╔══════════════════════════════════════════════════════════════════════╗"
  echo "║            Complete Zsh + Oh-My-Zsh + Plugins Setup                 ║"
  echo "║          Automated Development Environment Configuration             ║"
  echo "╚══════════════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

print_step() {
  echo -e "${BOLD}${CYAN}[STEP]${NC} $1"
}

print_success() {
  echo -e "${BOLD}${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${BOLD}${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${BOLD}${RED}[ERROR]${NC} $1"
}

print_info() {
  echo -e "${BOLD}${PURPLE}[INFO]${NC} $1"
}

# =============================================================================
# SYSTEM DETECTION AND PACKAGE MANAGEMENT
# =============================================================================

detect_system() {
  print_step "Detecting system configuration..."

  # Detect OS
  case "$(uname -s)" in
  Linux*) OS=Linux ;;
  Darwin*) OS=Mac ;;
  CYGWIN*) OS=Cygwin ;;
  MINGW*) OS=MinGw ;;
  *) OS="UNKNOWN:$(uname -s)" ;;
  esac

  # Detect package manager on Linux
  if [[ "$OS" == "Linux" ]]; then
    if command -v apt-get &>/dev/null; then
      PKG_MANAGER="apt"
      INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
    elif command -v yum &>/dev/null; then
      PKG_MANAGER="yum"
      INSTALL_CMD="sudo yum install -y"
    elif command -v dnf &>/dev/null; then
      PKG_MANAGER="dnf"
      INSTALL_CMD="sudo dnf install -y"
    elif command -v pacman &>/dev/null; then
      PKG_MANAGER="pacman"
      INSTALL_CMD="sudo pacman -S --noconfirm"
    elif command -v zypper &>/dev/null; then
      PKG_MANAGER="zypper"
      INSTALL_CMD="sudo zypper install -y"
    elif command -v apk &>/dev/null; then
      PKG_MANAGER="apk"
      INSTALL_CMD="sudo apk add"
    else
      PKG_MANAGER="unknown"
    fi
  elif [[ "$OS" == "Mac" ]]; then
    if command -v brew &>/dev/null; then
      PKG_MANAGER="brew"
      INSTALL_CMD="brew install"
    elif command -v port &>/dev/null; then
      PKG_MANAGER="macports"
      INSTALL_CMD="sudo port install"
    else
      PKG_MANAGER="unknown"
    fi
  fi

  print_info "Operating System: $OS"
  print_info "Package Manager: $PKG_MANAGER"
}

# =============================================================================
# ZSH INSTALLATION
# =============================================================================

install_zsh() {
  print_step "Installing zsh..."

  if command -v zsh &>/dev/null; then
    ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    print_success "zsh $ZSH_VERSION is already installed"
    return 0
  fi

  case $PKG_MANAGER in
  apt)
    sudo apt-get update && sudo apt-get install -y zsh
    ;;
  yum | dnf)
    $INSTALL_CMD zsh
    ;;
  pacman)
    $INSTALL_CMD zsh
    ;;
  zypper)
    $INSTALL_CMD zsh
    ;;
  apk)
    $INSTALL_CMD zsh
    ;;
  brew)
    brew install zsh
    ;;
  macports)
    sudo port install zsh
    ;;
  *)
    print_error "Could not install zsh automatically!"
    print_info "Please install zsh manually:"
    case $OS in
    Linux)
      echo "  Ubuntu/Debian: sudo apt-get install zsh"
      echo "  CentOS/RHEL:   sudo yum install zsh"
      echo "  Arch Linux:    sudo pacman -S zsh"
      ;;
    Mac)
      echo "  Homebrew:      brew install zsh"
      ;;
    esac
    exit 1
    ;;
  esac

  # Verify installation
  if command -v zsh &>/dev/null; then
    ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
    print_success "zsh $ZSH_VERSION installed successfully!"
  else
    print_error "zsh installation failed!"
    exit 1
  fi
}

set_zsh_as_default() {
  print_step "Setting zsh as default shell..."

  CURRENT_SHELL=$(echo $SHELL)
  ZSH_PATH=$(which zsh)

  if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
    print_success "zsh is already the default shell"
    return 0
  fi

  # Add zsh to /etc/shells if not present
  if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    print_step "Adding zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change default shell
  print_info "Changing default shell to zsh..."
  if chsh -s "$ZSH_PATH"; then
    print_success "Default shell changed to zsh"
    print_warning "You'll need to restart your terminal or login again for this to take effect"
  else
    print_warning "Could not change default shell automatically"
    print_info "Run manually: chsh -s $ZSH_PATH"
  fi
}

# =============================================================================
# OH-MY-ZSH INSTALLATION
# =============================================================================

install_oh_my_zsh() {
  print_step "Installing Oh-My-Zsh..."

  if [ -d "$OH_MY_ZSH_DIR" ]; then
    print_warning "Oh-My-Zsh is already installed at $OH_MY_ZSH_DIR"

    read -p "Do you want to reinstall Oh-My-Zsh? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_step "Backing up existing Oh-My-Zsh installation..."
      mv "$OH_MY_ZSH_DIR" "${OH_MY_ZSH_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
      if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d_%H%M%S)"
      fi
    else
      print_info "Keeping existing Oh-My-Zsh installation"
      return 0
    fi
  fi

  # Install Oh-My-Zsh
  print_step "Downloading and installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  if [ -d "$OH_MY_ZSH_DIR" ]; then
    print_success "Oh-My-Zsh installed successfully!"
  else
    print_error "Oh-My-Zsh installation failed!"
    exit 1
  fi
}

# =============================================================================
# POWERLEVEL10K INSTALLATION
# =============================================================================

install_powerlevel10k() {
  print_step "Installing Powerlevel10k theme..."

  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [ -d "$P10K_DIR" ]; then
    print_warning "Powerlevel10k is already installed"

    read -p "Do you want to update Powerlevel10k? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_step "Updating Powerlevel10k..."
      git -C "$P10K_DIR" pull
    fi
  else
    print_step "Cloning Powerlevel10k repository..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  fi

  # Update .zshrc to use powerlevel10k theme
  if [ -f "$ZSHRC" ]; then
    print_step "Configuring Powerlevel10k theme in .zshrc..."

    # Replace or add ZSH_THEME line
    if grep -q "^ZSH_THEME=" "$ZSHRC"; then
      sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
    else
      echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >>"$ZSHRC"
    fi

    print_success "Powerlevel10k theme configured!"
  else
    print_error ".zshrc not found! Oh-My-Zsh might not be properly installed."
    exit 1
  fi
}

# =============================================================================
# PLUGIN INSTALLATIONS
# =============================================================================

install_zsh_plugins() {
  print_step "Installing zsh plugins..."

  # Install zsh-autosuggestions
  install_zsh_autosuggestions

  # Install zsh-syntax-highlighting
  install_zsh_syntax_highlighting

  # Install eza (better ls)
  install_eza

  # Install zoxide (better cd)
  install_zoxide

  # Update .zshrc plugins array
  update_zshrc_plugins
}

install_zsh_autosuggestions() {
  print_step "Installing zsh-autosuggestions..."

  AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

  if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
    print_info "zsh-autosuggestions already installed, updating..."
    git -C "$AUTOSUGGESTIONS_DIR" pull
  else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
  fi

  print_success "zsh-autosuggestions installed!"
}

install_zsh_syntax_highlighting() {
  print_step "Installing zsh-syntax-highlighting..."

  HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  if [ -d "$HIGHLIGHTING_DIR" ]; then
    print_info "zsh-syntax-highlighting already installed, updating..."
    git -C "$HIGHLIGHTING_DIR" pull
  else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HIGHLIGHTING_DIR"
  fi

  print_success "zsh-syntax-highlighting installed!"
}

install_eza() {
  print_step "Installing eza (better ls)..."

  if command -v eza &>/dev/null; then
    EZA_VERSION=$(eza --version | head -1 | awk '{print $2}')
    print_success "eza $EZA_VERSION is already installed"

    read -p "Do you want to update eza to the latest version? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi
  fi

  # Install eza based on package manager
  case $PKG_MANAGER in
  apt)
    install_eza_ubuntu_debian
    ;;
  pacman)
    print_step "Installing eza via pacman..."
    if $INSTALL_CMD eza; then
      print_success "eza installed via pacman!"
    else
      print_warning "pacman installation failed, trying cargo fallback..."
      install_eza_cargo_fallback
    fi
    ;;
  zypper)
    print_step "Installing eza via zypper..."
    if $INSTALL_CMD eza; then
      print_success "eza installed via zypper!"
    else
      print_warning "zypper installation failed, trying cargo fallback..."
      install_eza_cargo_fallback
    fi
    ;;
  apk)
    print_step "Installing eza via apk..."
    if $INSTALL_CMD eza; then
      print_success "eza installed via apk!"
    else
      print_warning "apk installation failed, trying cargo fallback..."
      install_eza_cargo_fallback
    fi
    ;;
  brew)
    print_step "Installing eza via Homebrew..."
    if brew install eza; then
      print_success "eza installed via Homebrew!"
    else
      print_warning "Homebrew installation failed, trying cargo fallback..."
      install_eza_cargo_fallback
    fi
    ;;
  *)
    print_info "Package manager not supported, using cargo fallback..."
    install_eza_cargo_fallback
    ;;
  esac

  # Verify final installation
  if command -v eza &>/dev/null; then
    EZA_VERSION=$(eza --version | head -1 | awk '{print $2}' 2>/dev/null || echo "unknown")
    print_success "eza $EZA_VERSION is now available!"
  else
    print_warning "eza installation completed but command not found in PATH"
    print_info "You may need to restart your shell or check your PATH"
  fi
}

install_eza_ubuntu_debian() {
  print_step "Installing eza via official repository (Ubuntu/Debian)..."

  # Ensure gpg is installed
  print_step "Ensuring GPG is available..."
  if ! command -v gpg &>/dev/null; then
    sudo apt update
    sudo apt install -y gpg
  fi

  # Add eza repository
  print_step "Adding eza repository..."

  # Create keyrings directory
  sudo mkdir -p /etc/apt/keyrings

  # Download and add GPG key
  if wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg; then
    print_success "GPG key added successfully"
  else
    print_error "Failed to download GPG key"
    print_warning "Trying cargo fallback..."
    install_eza_cargo_fallback
    return
  fi

  # Add repository to sources
  if echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null; then
    print_success "Repository added to sources"
  else
    print_error "Failed to add repository"
    print_warning "Trying cargo fallback..."
    install_eza_cargo_fallback
    return
  fi

  # Set correct permissions
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

  # Update package list
  print_step "Updating package list..."
  if sudo apt update; then
    print_success "Package list updated"
  else
    print_warning "Package update had warnings, continuing..."
  fi

  # Install eza
  print_step "Installing eza from repository..."
  if sudo apt install -y eza; then
    print_success "eza installed successfully from official repository!"
  else
    print_error "Failed to install eza from repository"
    print_warning "Trying cargo fallback..."
    install_eza_cargo_fallback
  fi
}

install_eza_cargo_fallback() {
  print_step "Installing eza via cargo (fallback method)..."

  # Simple cargo installation without complex version checking
  install_cargo_simple

  # Make sure cargo is in PATH
  if ! command -v cargo &>/dev/null; then
    if [ -f "$HOME/.cargo/env" ]; then
      source "$HOME/.cargo/env"
    fi
    if [ -d "$HOME/.cargo/bin" ]; then
      export PATH="$HOME/.cargo/bin:$PATH"
    fi
  fi

  if ! command -v cargo &>/dev/null; then
    print_error "Cargo is not available, cannot install eza"
    print_warning "Continuing setup without eza..."
    return 1
  fi

  # Try to install eza with cargo
  print_info "This may take a few minutes as eza will be compiled from source..."
  if cargo install eza; then
    print_success "eza installed successfully via cargo!"

    # Add cargo bin to PATH if needed
    if [ -d "$HOME/.cargo/bin" ] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
      export PATH="$HOME/.cargo/bin:$PATH"
    fi
  else
    print_error "eza installation via cargo failed!"
    print_info "You can try installing it manually later:"
    echo -e "  ${BLUE}cargo install eza${NC}"
    print_warning "Continuing setup without eza..."
    return 1
  fi
}

install_cargo_simple() {
  if command -v cargo &>/dev/null; then
    return 0
  fi

  print_step "Installing Rust and Cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal

  if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
  fi

  if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
}

install_zoxide() {
  print_step "Installing zoxide (better cd)..."

  if command -v zoxide &>/dev/null; then
    print_success "zoxide is already installed"
    return 0
  fi

  case $PKG_MANAGER in
  pacman)
    if $INSTALL_CMD zoxide; then
      print_success "zoxide installed via pacman!"
      return 0
    fi
    ;;
  zypper)
    if $INSTALL_CMD zoxide; then
      print_success "zoxide installed via zypper!"
      return 0
    fi
    ;;
  apk)
    if $INSTALL_CMD zoxide; then
      print_success "zoxide installed via apk!"
      return 0
    fi
    ;;
  brew)
    if brew install zoxide; then
      print_success "zoxide installed via Homebrew!"
      return 0
    fi
    ;;
  esac

  # Universal installation method via curl script
  print_step "Installing zoxide via installation script..."
  if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
    print_success "zoxide installed successfully!"

    # Check if zoxide is in PATH
    if command -v zoxide &>/dev/null; then
      print_success "zoxide is available in PATH"
    elif [ -f "$HOME/.local/bin/zoxide" ]; then
      print_info "zoxide installed to ~/.local/bin/zoxide"

      # Add to current session PATH
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        print_info "Added ~/.local/bin to current session PATH"

        # Verify it's now available
        if command -v zoxide &>/dev/null; then
          print_success "zoxide is now available in PATH"
        else
          print_warning "zoxide still not found in PATH"
        fi
      fi

      # Add to .zshrc if needed (will be handled by custom config append)
      print_info "~/.local/bin will be added to PATH in .zshrc"
    else
      print_warning "zoxide installation completed but binary not found"
    fi
  else
    print_warning "zoxide installation may have failed, but continuing..."
  fi
}

update_zshrc_plugins() {
  print_step "Updating .zshrc plugins configuration..."

  if [ ! -f "$ZSHRC" ]; then
    print_error ".zshrc not found!"
    return 1
  fi

  # Define the plugins we want to add
  PLUGINS_TO_ADD="git zsh-autosuggestions zsh-syntax-highlighting"

  # Check if plugins line exists
  if grep -q "^plugins=" "$ZSHRC"; then
    print_info "Found existing plugins configuration, updating..."

    # Get current plugins (extract content between parentheses)
    CURRENT_PLUGINS=$(grep "^plugins=" "$ZSHRC" | sed 's/^plugins=(//' | sed 's/).*$//' | tr -d '"' | tr -d "'" | tr '\n' ' ' | tr -s ' ')

    # Build new plugins list
    NEW_PLUGINS=""

    # Add existing plugins first (avoid duplicates)
    for plugin in $CURRENT_PLUGINS; do
      # Skip empty plugins and whitespace
      if [ -n "$plugin" ] && [ "$plugin" != " " ]; then
        if [ -z "$NEW_PLUGINS" ]; then
          NEW_PLUGINS="$plugin"
        else
          NEW_PLUGINS="$NEW_PLUGINS $plugin"
        fi
      fi
    done

    # Add new plugins if not already present
    for plugin in $PLUGINS_TO_ADD; do
      if ! echo " $NEW_PLUGINS " | grep -q " $plugin "; then
        if [ -z "$NEW_PLUGINS" ]; then
          NEW_PLUGINS="$plugin"
        else
          NEW_PLUGINS="$NEW_PLUGINS $plugin"
        fi
      fi
    done

    # Create backup
    cp "$ZSHRC" "$ZSHRC.bak"

    # Use a temporary file to avoid sed issues
    TEMP_FILE=$(mktemp)

    # Copy everything except the plugins line to temp file
    grep -v "^plugins=" "$ZSHRC" >"$TEMP_FILE"

    # Add the new plugins line
    echo "plugins=($NEW_PLUGINS)" >>"$TEMP_FILE"

    # Replace original file
    mv "$TEMP_FILE" "$ZSHRC"

  else
    print_info "No existing plugins configuration found, adding new one..."

    # Add plugins line at the end
    echo "" >>"$ZSHRC"
    echo "plugins=($PLUGINS_TO_ADD)" >>"$ZSHRC"
  fi

  print_success "Updated .zshrc plugins configuration!"

  # Show what plugins are now configured
  if grep -q "^plugins=" "$ZSHRC"; then
    FINAL_PLUGINS=$(grep "^plugins=" "$ZSHRC")
    print_info "Configured plugins: $FINAL_PLUGINS"
  fi
}

# =============================================================================
# CUSTOM CONFIGURATION APPEND
# =============================================================================

append_custom_config() {
  print_step "Appending custom configurations from dotfiles..."

  # Check if dotfiles directory exists
  if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found at: $DOTFILES_DIR"
    print_info "Please clone your dotfiles repository to ~/dot-files first"
    exit 1
  fi

  # Check if custom zsh config exists
  if [ ! -f "$ZSH_CONFIG_APPEND" ]; then
    print_error "Custom zsh config not found at: $ZSH_CONFIG_APPEND"
    print_info "Expected file structure:"
    print_info "  ~/dot-files/zsh/zshrc-append"
    exit 1
  fi

  print_success "Found custom zsh config at: $ZSH_CONFIG_APPEND"

  # Check if already appended
  if grep -q "# === CUSTOM DOTFILES CONFIGURATION ===" "$ZSHRC" 2>/dev/null; then
    print_warning "Custom configuration already appended to .zshrc"

    read -p "Do you want to re-append the configuration? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Remove old custom configuration
      print_step "Removing previous custom configuration..."
      sed -i.bak '/# === CUSTOM DOTFILES CONFIGURATION ===/,$d' "$ZSHRC"
    else
      print_info "Skipping custom configuration append"
      return 0
    fi
  fi

  # Append custom configuration
  print_step "Appending your custom configuration..."

  echo "" >>"$ZSHRC"
  echo "# === CUSTOM DOTFILES CONFIGURATION ===" >>"$ZSHRC"
  echo "# Appended by install-zsh-setup.sh" >>"$ZSHRC"
  echo "# Source: $ZSH_CONFIG_APPEND" >>"$ZSHRC"
  echo "" >>"$ZSHRC"

  cat "$ZSH_CONFIG_APPEND" >>"$ZSHRC"

  print_success "Custom configuration appended successfully!"
  print_info "Custom config source: $ZSH_CONFIG_APPEND"
}

# =============================================================================
# CONFIGURATION PROMPT
# =============================================================================

prompt_powerlevel10k_config() {
  print_step "Powerlevel10k configuration..."

  echo -e "${BOLD}${CYAN}Powerlevel10k Theme Configuration${NC}"
  echo -e "${YELLOW}Powerlevel10k will prompt you to configure your theme when you start zsh.${NC}"
  echo -e "${YELLOW}This includes setting up icons, prompt style, colors, etc.${NC}"
  echo
  echo -e "${BOLD}${CYAN}To manually configure later, run:${NC}"
  echo -e "  ${BLUE}p10k configure${NC}"
  echo

  read -p "Do you want to start zsh now to configure Powerlevel10k? [Y/n]: " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Starting zsh for Powerlevel10k configuration..."
    print_info "After configuration, type 'exit' to return to this script"
    echo
    exec zsh
  else
    print_info "You can configure Powerlevel10k later by running: p10k configure"
  fi
}

# =============================================================================
# MAIN INSTALLATION FLOW
# =============================================================================

main() {
  print_header

  # Parse command line arguments
  APPEND_ONLY=false
  for arg in "$@"; do
    case $arg in
    --append-only)
      APPEND_ONLY=true
      shift
      ;;
    --help | -h)
      echo "Usage: $0 [--append-only]"
      echo ""
      echo "Options:"
      echo "  --append-only    Skip installations, only append custom configurations"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
    *)
      print_warning "Unknown option: $arg"
      ;;
    esac
  done

  if [[ "$APPEND_ONLY" == true ]]; then
    print_info "Append-only mode: Skipping installations"

    # Verify prerequisites for append-only mode
    if [ ! -f "$ZSHRC" ]; then
      print_error ".zshrc not found! Oh-My-Zsh needs to be installed first."
      print_info "Run without --append-only flag to do full installation."
      exit 1
    fi

    append_custom_config
    print_success "Custom configuration append completed!"
    print_info "Restart zsh to see changes: exec zsh"
    exit 0
  fi

  # Full installation
  detect_system
  install_zsh
  set_zsh_as_default
  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  append_custom_config

  # Show completion message and offer configuration
  print_completion_summary
  prompt_powerlevel10k_config
}

# =============================================================================
# COMPLETION SUMMARY
# =============================================================================

print_completion_summary() {
  echo
  echo -e "${BOLD}${GREEN}🎉 Complete Zsh Setup Successful! 🎉${NC}"
  echo
  echo -e "${BOLD}${CYAN}What was installed and configured:${NC}"
  echo -e "   ✅ ${GREEN}zsh${NC} - Z shell"
  echo -e "   ✅ ${GREEN}oh-my-zsh${NC} - Zsh framework"
  echo -e "   ✅ ${GREEN}powerlevel10k${NC} - Beautiful prompt theme"
  echo -e "   ✅ ${GREEN}zsh-autosuggestions${NC} - Command suggestions"
  echo -e "   ✅ ${GREEN}zsh-syntax-highlighting${NC} - Syntax coloring"
  if command -v cargo &>/dev/null; then
    RUSTC_VERSION=$(rustc --version | cut -d' ' -f2 2>/dev/null || echo "unknown")
    echo -e "   ✅ ${GREEN}Rust & Cargo${NC} - Latest stable ($RUSTC_VERSION)"
  fi
  if command -v eza &>/dev/null; then
    EZA_VERSION=$(eza --version | head -1 | awk '{print $2}' 2>/dev/null || echo "unknown")
    echo -e "   ✅ ${GREEN}eza${NC} - Enhanced ls command ($EZA_VERSION)"
  else
    echo -e "   ⚠️  ${YELLOW}eza${NC} - Installation skipped (compatibility issues)"
  fi
  if command -v zoxide &>/dev/null; then
    echo -e "   ✅ ${GREEN}zoxide${NC} - Smart cd command"
  else
    echo -e "   ⚠️  ${YELLOW}zoxide${NC} - Installation may have failed"
  fi
  echo -e "   ✅ ${GREEN}Custom configuration${NC} - Your dotfiles appended"
  echo
  echo -e "${BOLD}${CYAN}Configuration Details:${NC}"
  echo -e "   📂 Dotfiles: ${BLUE}$DOTFILES_DIR${NC}"
  echo -e "   📄 Custom config: ${BLUE}$ZSH_CONFIG_APPEND${NC}"
  echo -e "   📄 Target .zshrc: ${BLUE}$ZSHRC${NC}"
  echo -e "   🎨 Theme: ${BLUE}powerlevel10k${NC}"
  echo
  echo -e "${BOLD}${CYAN}Next Steps:${NC}"
  echo -e "   ${YELLOW}1.${NC} Configure powerlevel10k (prompted below)"
  echo -e "   ${YELLOW}2.${NC} Restart your terminal or run: ${BLUE}exec zsh${NC}"
  echo -e "   ${YELLOW}3.${NC} Enjoy your enhanced shell experience!"
  echo
  echo -e "${BOLD}${CYAN}Managing Configuration:${NC}"
  echo -e "   📝 Edit: ${BLUE}$ZSH_CONFIG_APPEND${NC}"
  echo -e "   📝 Update: ${BLUE}./install-zsh-setup.sh --append-only${NC}"
  echo -e "   📝 Re-configure theme: ${BLUE}p10k configure${NC}"
  echo
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Handle script interruption
trap 'echo -e "\n${RED}Installation interrupted by user.${NC}"; exit 1' INT

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
