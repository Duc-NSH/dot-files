#!/bin/bash

# =============================================================================
# Complete Tmux + TPM Installation Script
# =============================================================================
# Description: Installs tmux, TPM, and sets up a complete development environment
# Author: DucNSH
# Usage: ./install.sh
# Features: Auto-detects OS, installs tmux, sets up TPM, creates optimized config
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

# TPM configuration
TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"
# Configuration paths for dotfiles repo
DOTFILES_DIR="$HOME/dot-files"
TMUX_CONFIG_SOURCE="$DOTFILES_DIR/tmux/tmux.conf"
TMUX_CONF="$HOME/.tmux.conf"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
  echo -e "${BOLD}${BLUE}"
  echo "╔══════════════════════════════════════════════════════════════════════╗"
  echo "║                Complete Tmux + TPM Setup Script                     ║"
  echo "║           Automated tmux & Plugin Manager Installation              ║"
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

install_dependencies() {
  print_step "Installing system dependencies..."

  # Install git if not present
  if ! command -v git &>/dev/null; then
    print_step "Installing git..."
    case $PKG_MANAGER in
    apt)
      sudo apt-get update && sudo apt-get install -y git
      ;;
    yum | dnf)
      $INSTALL_CMD git
      ;;
    pacman)
      $INSTALL_CMD git
      ;;
    zypper)
      $INSTALL_CMD git
      ;;
    apk)
      $INSTALL_CMD git
      ;;
    brew)
      brew install git
      ;;
    macports)
      sudo port install git
      ;;
    *)
      print_error "Could not install git automatically."
      print_info "Please install git manually and run this script again."
      exit 1
      ;;
    esac
    print_success "Git installed successfully!"
  else
    print_success "Git is already installed."
  fi

  # Install bc for version comparison (Linux only)
  if [[ "$OS" == "Linux" ]] && ! command -v bc &>/dev/null; then
    print_step "Installing bc (calculator for version comparison)..."
    case $PKG_MANAGER in
    apt)
      sudo apt-get install -y bc
      ;;
    yum | dnf)
      $INSTALL_CMD bc
      ;;
    pacman)
      $INSTALL_CMD bc
      ;;
    zypper)
      $INSTALL_CMD bc
      ;;
    apk)
      $INSTALL_CMD bc
      ;;
    esac
  fi
}

check_tmux_installation() {
  print_step "Checking tmux installation..."

  if command -v tmux &>/dev/null; then
    CURRENT_TMUX_VERSION=$(tmux -V | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    print_info "tmux version $CURRENT_TMUX_VERSION is installed."

    # Check if it's a recent version (3.0+)
    if [[ $(echo "$CURRENT_TMUX_VERSION >= 3.0" | bc -l 2>/dev/null || echo "0") -eq 1 ]]; then
      print_success "tmux version is recent and compatible!"
      return 0
    else
      print_warning "tmux version $CURRENT_TMUX_VERSION is quite old."
      read -p "Do you want to upgrade tmux? [y/N]: " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_tmux
        return $?
      else
        print_info "Continuing with current tmux version..."
        return 0
      fi
    fi
  else
    print_warning "tmux is not installed."
    install_tmux
    return $?
  fi
}

install_tmux() {
  print_step "Installing tmux..."

  case $PKG_MANAGER in
  apt)
    print_info "Using apt package manager..."
    sudo apt-get update
    sudo apt-get install -y tmux
    ;;
  yum)
    print_info "Using yum package manager..."
    sudo yum install -y tmux
    ;;
  dnf)
    print_info "Using dnf package manager..."
    sudo dnf install -y tmux
    ;;
  pacman)
    print_info "Using pacman package manager..."
    sudo pacman -Sy --noconfirm tmux
    ;;
  zypper)
    print_info "Using zypper package manager..."
    sudo zypper refresh
    sudo zypper install -y tmux
    ;;
  apk)
    print_info "Using apk package manager..."
    sudo apk update
    sudo apk add tmux
    ;;
  brew)
    print_info "Using Homebrew..."
    brew install tmux
    ;;
  macports)
    print_info "Using MacPorts..."
    sudo port selfupdate
    sudo port install tmux
    ;;
  unknown)
    print_error "Could not detect package manager!"
    print_info "Please install tmux manually:"
    case $OS in
    Linux)
      echo "  Ubuntu/Debian: sudo apt-get install tmux"
      echo "  CentOS/RHEL:   sudo yum install tmux"
      echo "  Arch Linux:    sudo pacman -S tmux"
      echo "  openSUSE:      sudo zypper install tmux"
      echo "  Alpine:        sudo apk add tmux"
      ;;
    Mac)
      echo "  Homebrew:      brew install tmux"
      echo "  MacPorts:      sudo port install tmux"
      ;;
    esac
    exit 1
    ;;
  *)
    print_error "Unsupported package manager: $PKG_MANAGER"
    exit 1
    ;;
  esac

  # Verify installation
  if command -v tmux &>/dev/null; then
    NEW_VERSION=$(tmux -V | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    print_success "tmux $NEW_VERSION installed successfully!"
    return 0
  else
    print_error "tmux installation failed!"
    return 1
  fi
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
  print_step "Running final prerequisite checks..."

  # Detect system and package manager
  detect_system

  # Install dependencies
  install_dependencies

  # Check/install tmux
  if ! check_tmux_installation; then
    print_error "tmux installation/verification failed!"
    exit 1
  fi

  # Final verification
  TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
  print_success "All prerequisites met!"
  print_info "tmux version: $TMUX_VERSION"
  print_info "Git version: $(git --version | cut -d' ' -f3)"
}

# =============================================================================
# TPM INSTALLATION
# =============================================================================

check_existing_installation() {
  print_step "Checking for existing TPM installation..."

  if [ -d "$TPM_DIR" ]; then
    print_warning "TPM directory already exists at: $TPM_DIR"

    if [ -f "$TPM_DIR/tpm" ]; then
      print_info "TPM appears to be already installed."
      read -p "Do you want to reinstall/update TPM? [y/N]: " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled by user."
        exit 0
      fi

      print_step "Backing up existing TPM installation..."
      mv "$TPM_DIR" "${TPM_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
      print_success "Backup created successfully!"
    fi
  fi
}

create_directories() {
  print_step "Creating directory structure..."

  # Create tmux plugins directory
  mkdir -p "$(dirname "$TPM_DIR")"
  print_success "Created directory: $(dirname "$TPM_DIR")"
}

clone_tpm() {
  print_step "Cloning TPM repository..."

  if git clone "$TPM_REPO" "$TPM_DIR"; then
    print_success "TPM cloned successfully to: $TPM_DIR"
  else
    print_error "Failed to clone TPM repository!"
    exit 1
  fi
}

# =============================================================================
# TMUX CONFIGURATION SETUP
# =============================================================================

# =============================================================================
# DOTFILES SYMLINK SETUP
# =============================================================================

setup_tmux_symlink() {
  print_step "Setting up tmux configuration symlink..."

  # Check if dotfiles directory exists
  if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found at: $DOTFILES_DIR"
    print_info "Please clone your dotfiles repository to ~/dot-files first:"
    print_info "  git clone <your-repo-url> ~/dot-files"
    exit 1
  fi

  # Check if tmux config exists in dotfiles
  if [ ! -f "$TMUX_CONFIG_SOURCE" ]; then
    print_error "tmux.conf not found at: $TMUX_CONFIG_SOURCE"
    print_info "Expected file structure:"
    print_info "  ~/dot-files/tmux/tmux.conf"
    exit 1
  fi

  print_success "Found tmux config at: $TMUX_CONFIG_SOURCE"

  # Handle existing tmux.conf
  if [ -e "$TMUX_CONF" ]; then
    if [ -L "$TMUX_CONF" ]; then
      CURRENT_TARGET=$(readlink "$TMUX_CONF")
      if [ "$CURRENT_TARGET" = "$TMUX_CONFIG_SOURCE" ]; then
        print_success "Symlink already correctly configured!"
        return
      else
        print_warning "Existing symlink points to: $CURRENT_TARGET"
        print_step "Updating symlink to point to dotfiles..."
        rm "$TMUX_CONF"
      fi
    else
      print_warning "Existing tmux.conf found (not a symlink)"
      print_step "Backing up existing config..."
      mv "$TMUX_CONF" "${TMUX_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
      print_success "Backup created!"
    fi
  fi

  # Create the symlink
  print_step "Creating symlink: $TMUX_CONF -> $TMUX_CONFIG_SOURCE"
  if ln -s "$TMUX_CONFIG_SOURCE" "$TMUX_CONF"; then
    print_success "Symlink created successfully!"
  else
    print_error "Failed to create symlink!"
    exit 1
  fi

  # Verify the symlink
  if [ -L "$TMUX_CONF" ] && [ -f "$TMUX_CONF" ]; then
    print_success "Symlink verification passed!"
    print_info "~/.tmux.conf -> $(readlink "$TMUX_CONF")"
  else
    print_error "Symlink verification failed!"
    exit 1
  fi

  # Check if TPM configuration exists in the config
  if grep -q "tmux-plugins/tpm" "$TMUX_CONFIG_SOURCE" 2>/dev/null; then
    print_success "TPM plugin configuration found in tmux.conf"

    if grep -q "run.*tpm/tpm" "$TMUX_CONFIG_SOURCE" 2>/dev/null; then
      print_success "TPM initialization found in tmux.conf"
    else
      print_warning "TPM plugin declared but initialization line missing"
      print_info "Make sure your tmux.conf ends with:"
      echo -e "   ${BLUE}run '~/.tmux/plugins/tpm/tpm'${NC}"
    fi
  else
    print_warning "TPM configuration not found in tmux.conf"
    print_info "Add these lines to $TMUX_CONFIG_SOURCE:"
    echo -e "   ${BLUE}set -g @plugin 'tmux-plugins/tpm'${NC}"
    echo -e "   ${BLUE}run '~/.tmux/plugins/tpm/tpm'${NC}"
  fi
}

# =============================================================================
# POST-INSTALLATION SETUP
# =============================================================================

reload_tmux_config() {
  print_step "Reloading tmux configuration..."

  # Check if tmux is running
  if tmux list-sessions &>/dev/null; then
    print_info "tmux is running. Reloading configuration..."
    tmux source-file "$TMUX_CONF" 2>/dev/null && {
      print_success "tmux configuration reloaded!"
    } || {
      print_warning "Could not reload tmux config automatically. Please reload manually."
    }
  else
    print_info "No active tmux sessions. Configuration will be loaded on next tmux start."
  fi
}

print_next_steps() {
  echo
  echo -e "${BOLD}${GREEN}🎉 Complete Tmux + TPM Installation Successful! 🎉${NC}"
  echo
  echo -e "${BOLD}${CYAN}What was installed:${NC}"
  echo -e "   ✅ ${GREEN}tmux${NC} - Terminal multiplexer"
  echo -e "   ✅ ${GREEN}TPM${NC} - Tmux Plugin Manager"
  echo -e "   ✅ ${GREEN}Comprehensive tmux.conf${NC} - Optimized for data engineering"
  echo -e "   ✅ ${GREEN}Essential dependencies${NC} - git and utilities"
  echo
  echo -e "${BOLD}${CYAN}Quick Start:${NC}"
  echo -e "${YELLOW}1.${NC} Start your first tmux session:"
  echo -e "   ${BLUE}tmux${NC} or ${BLUE}tmux new -s my-project${NC}"
  echo
  echo -e "${YELLOW}2.${NC} Install recommended plugins:"
  echo -e "   Press ${BOLD}${BLUE}Ctrl+a + I${NC} to install plugins"
  echo
  echo -e "${YELLOW}3.${NC} Essential tmux commands:"
  echo -e "   ${BLUE}Ctrl+a + |${NC}     - Split pane horizontally"
  echo -e "   ${BLUE}Ctrl+a + -${NC}     - Split pane vertically"
  echo -e "   ${BLUE}Ctrl+a + m${NC}     - Toggle pane zoom"
  echo -e "   ${BLUE}Ctrl+a + r${NC}     - Reload configuration"
  echo -e "   ${BLUE}Ctrl+a + d${NC}     - Detach from session"
  echo
  echo -e "${BOLD}${CYAN}Plugin Management with TPM:${NC}"
  echo -e "   ${BLUE}Ctrl+a + I${NC}       - Install new plugins"
  echo -e "   ${BLUE}Ctrl+a + U${NC}       - Update all plugins"
  echo -e "   ${BLUE}Ctrl+a + alt + u${NC} - Remove unused plugins"
  echo
  echo -e "${BOLD}${CYAN}Recommended Plugins to Enable:${NC}"
  echo -e "Edit ${BLUE}~/.tmux.conf${NC} and uncomment these lines:"
  echo -e "   ${GREEN}set -g @plugin 'tmux-plugins/tmux-resurrect'${NC}     # Session persistence"
  echo -e "   ${GREEN}set -g @plugin 'tmux-plugins/tmux-continuum'${NC}     # Auto-save sessions"
  echo -e "   ${GREEN}set -g @plugin 'christoomey/vim-tmux-navigator'${NC}  # Vim integration"
  echo -e "   ${GREEN}set -g @plugin 'catppuccin/tmux'${NC}                 # Beautiful theme"
  echo -e "   ${GREEN}set -g @plugin 'tmux-plugins/tmux-cpu'${NC}           # System monitoring"
  echo
  echo -e "${BOLD}${CYAN}Data Engineering Workflow Tips:${NC}"
  echo -e "   🔹 Create dedicated sessions per project: ${BLUE}tmux new -s data-pipeline${NC}"
  echo -e "   🔹 Use multiple windows: Editor, Server, Database, Logs, Monitoring"
  echo -e "   🔹 Split panes for side-by-side development and monitoring"
  echo -e "   🔹 Use session persistence to restore work after reboots"
  echo
  echo -e "${BOLD}${CYAN}Useful Tmux Sessions for Data Engineering:${NC}"
  echo -e "   ${BLUE}tmux new -s ml-pipeline${NC}     # Machine learning projects"
  echo -e "   ${BLUE}tmux new -s data-viz${NC}        # Data visualization work"
  echo -e "   ${BLUE}tmux new -s api-dev${NC}         # API development"
  echo -e "   ${BLUE}tmux new -s monitoring${NC}      # System/app monitoring"
  echo
  echo -e "${BOLD}${CYAN}Configuration Files:${NC}"
  echo -e "   Config: ${BLUE}$TMUX_CONF${NC}"
  echo -e "   TPM:    ${BLUE}$TPM_DIR${NC}"
  echo -e "   Logs:   ${BLUE}~/.tmux/resurrect/${NC} (when using tmux-resurrect)"
  echo
  echo -e "${BOLD}${CYAN}Getting Help:${NC}"
  echo -e "   ${BLUE}man tmux${NC}         - Tmux manual"
  echo -e "   ${BLUE}Ctrl+a + ?${NC}       - Show all tmux key bindings"
  echo -e "   ${BLUE}tmux list-sessions${NC} - List all sessions"
  echo -e "   ${BLUE}tmux attach -t <name>${NC} - Attach to named session"
  echo
  echo -e "${BOLD}${GREEN}Happy coding with your new tmux setup! 🚀${NC}"
  echo -e "${CYAN}Perfect for data engineering, ML development, and system monitoring!${NC}"
}

# =============================================================================
# MAIN INSTALLATION FLOW
# =============================================================================

main() {
  print_header

  # Parse command line arguments
  SKIP_TMUX=false
  for arg in "$@"; do
    case $arg in
    --tpm-only)
      SKIP_TMUX=true
      shift
      ;;
    --help | -h)
      echo "Usage: $0 [--tpm-only]"
      echo ""
      echo "Options:"
      echo "  --tpm-only    Skip tmux installation, only install TPM"
      echo "  --help, -h    Show this help message"
      exit 0
      ;;
    *)
      print_warning "Unknown option: $arg"
      ;;
    esac
  done

  if [[ "$SKIP_TMUX" == true ]]; then
    print_info "TPM-only mode: Skipping tmux installation"
    # Just check that tmux exists
    if ! command -v tmux &>/dev/null; then
      print_error "tmux is not installed! Cannot install TPM without tmux."
      print_info "Run without --tpm-only flag to install tmux first."
      exit 1
    fi

    if ! command -v git &>/dev/null; then
      print_error "git is not installed!"
      print_info "Run without --tpm-only flag to install git automatically."
      exit 1
    fi

    TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
    print_info "Using existing tmux version: $TMUX_VERSION"
  else
    # Full installation with tmux
    check_prerequisites
  fi

  # Run TPM installation steps
  check_existing_installation
  create_directories
  clone_tpm
  setup_tmux_symlink
  reload_tmux_config

  # Show completion message
  print_next_steps
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
