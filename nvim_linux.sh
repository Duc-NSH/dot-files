#!/bin/bash

# Neovim User-Specific Installation & Uninstallation Script with Explicit Shell Argument

# Variables
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
INSTALL_DIR="$HOME/.local/bin"
NVIM_BIN="$INSTALL_DIR/nvim"
CONFIG_FILE=""
SUPPORTED_SHELLS=("bash" "zsh" "fish" "ksh")

# 🛠️ Function to Display Help
show_help() {
    echo "🔧 Neovim Installer Script"
    echo ""
    echo "Usage:"
    echo "  $0 install --shell <shell>    Install Neovim (supported shells: bash, zsh, fish, ksh)"
    echo "  $0 uninstall --shell <shell>  Uninstall Neovim"
    echo "  $0 help                      Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install --shell bash"
    echo "  $0 uninstall --shell zsh"
}

# 🛡️ Validate Shell Argument
validate_shell() {
    local shell=$1
    if [[ ! " ${SUPPORTED_SHELLS[*]} " =~ " ${shell} " ]]; then
        echo "❌ Unsupported shell: $shell"
        echo "Supported shells are: ${SUPPORTED_SHELLS[*]}"
        exit 1
    fi
}

# 📂 Set Shell Configuration File
set_shell_config() {
    local shell=$1
    case "$shell" in
        bash)
            CONFIG_FILE="$HOME/.bashrc"
            ;;
        zsh)
            CONFIG_FILE="$HOME/.zshrc"
            ;;
        fish)
            CONFIG_FILE="$HOME/.config/fish/config.fish"
            ;;
        ksh)
            CONFIG_FILE="$HOME/.kshrc"
            ;;
    esac
    echo "📝 Configuration File: $CONFIG_FILE"
}

# 🛠️ Add PATH to Shell Config
add_path_to_shell_config() {
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$CONFIG_FILE"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CONFIG_FILE"
        echo "✅ Added ~/.local/bin to PATH in $CONFIG_FILE"
    else
        echo "ℹ️ ~/.local/bin is already in PATH in $CONFIG_FILE"
    fi

    # Notify the user to reload their shell
    echo "🔄 Please run the following command to reload your shell:"
    echo "   source $CONFIG_FILE"
}

# 🧹 Remove PATH from Shell Config
remove_path_from_shell_config() {
    if grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$CONFIG_FILE"; then
        sed -i '/export PATH="\$HOME\/.local\/bin:\$PATH"/d' "$CONFIG_FILE"
        echo "✅ Removed ~/.local/bin from PATH in $CONFIG_FILE"
    else
        echo "ℹ️ ~/.local/bin was not found in PATH in $CONFIG_FILE"
    fi

    # Notify the user to reload their shell
    echo "🔄 Please run the following command to reload your shell:"
    echo "   source $CONFIG_FILE"
}

# 📦 Install Neovim
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

# 🗑️ Uninstall Neovim
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

# 🚦 Main Script Logic
ACTION=$1
SHELL_NAME=""

case "$ACTION" in
    help)
        show_help
        exit 0
        ;;
    install|uninstall)
        if [[ "$2" == "--shell" && -n "$3" ]]; then
            SHELL_NAME=$3
            validate_shell "$SHELL_NAME"
            set_shell_config "$SHELL_NAME"
        else
            echo "❌ Error: Please specify --shell <shell> argument."
            show_help
            exit 1
        fi
        ;;
    *)
        echo "⚠️ Invalid option!"
        show_help
        exit 1
        ;;
esac

# Perform Action
case "$ACTION" in
    install)
        install_nvim
        ;;
    uninstall)
        uninstall_nvim
        ;;
esac
