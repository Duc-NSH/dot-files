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
    print_success "eza is already installed"
    return 0
  fi

  case $PKG_MANAGER in
  apt)
    # For Ubuntu/Debian, need to install from cargo or snap
    if command -v cargo &>/dev/null; then
      cargo install eza
    elif command -v snap &>/dev/null; then
      sudo snap install eza
    else
      print_warning "Installing rust/cargo first for eza..."
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
      cargo install eza
    fi
    ;;
  yum | dnf)
    # Try to install via cargo
    if ! command -v cargo &>/dev/null; then
      $INSTALL_CMD rust cargo
    fi
    cargo install eza
    ;;
  pacman)
    $INSTALL_CMD eza
    ;;
  zypper)
    $INSTALL_CMD eza
    ;;
  apk)
    $INSTALL_CMD eza
    ;;
  brew)
    brew install eza
    ;;
  *)
    print_warning "Installing eza via cargo..."
    if ! command -v cargo &>/dev/null; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
    fi
    cargo install eza
    ;;
  esac

  if command -v eza &>/dev/null; then
    print_success "eza installed successfully!"
  else
    print_warning "eza installation may have failed, but continuing..."
  fi
}

install_zoxide() {
  print_step "Installing zoxide (better cd)..."

  if command -v zoxide &>/dev/null; then
    print_success "zoxide is already installed"
    return 0
  fi

  case $PKG_MANAGER in
  apt)
    # Install via curl script or cargo
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    ;;
  yum | dnf)
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    ;;
  pacman)
    $INSTALL_CMD zoxide
    ;;
  zypper)
    $INSTALL_CMD zoxide
    ;;
  apk)
    $INSTALL_CMD zoxide
    ;;
  brew)
    brew install zoxide
    ;;
  *)
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    ;;
  esac

  # Add to PATH if installed in ~/.local/bin
  if [ -f "$HOME/.local/bin/zoxide" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$ZSHRC"
  fi

  if command -v zoxide &>/dev/null || [ -f "$HOME/.local/bin/zoxide" ]; then
    print_success "zoxide installed successfully!"
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
    # Get current plugins
    CURRENT_PLUGINS=$(grep "^plugins=" "$ZSHRC" | sed 's/plugins=(//' | sed 's/)//' | tr -d '"' | tr -d "'" | tr '\n' ' ')

    # Add new plugins if not already present
    for plugin in $PLUGINS_TO_ADD; do
      if [[ ! "$CURRENT_PLUGINS" =~ $plugin ]]; then
        CURRENT_PLUGINS="$CURRENT_PLUGINS $plugin"
      fi
    done

    # Update plugins line
    FORMATTED_PLUGINS=$(echo "$CURRENT_PLUGINS" | xargs | sed 's/ /\n  /g')
    sed -i.bak "s/^plugins=.*/plugins=(\n  $FORMATTED_PLUGINS\n)/" "$ZSHRC"
  else
    # Add plugins line
    echo "" >>"$ZSHRC"
    echo "plugins=(" >>"$ZSHRC"
    for plugin in $PLUGINS_TO_ADD; do
      echo "  $plugin" >>"$ZSHRC"
    done
    echo ")" >>"$ZSHRC"
  fi

  print_success "Updated .zshrc plugins configuration!"
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
    print_info "  ~/dot-files/zsh/.zshrc"
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
  echo -e "   ✅ ${GREEN}eza${NC} - Enhanced ls command"
  echo -e "   ✅ ${GREEN}zoxide${NC} - Smart cd command"
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
