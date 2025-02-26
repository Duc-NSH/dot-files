# dot-files

<!--toc:start-->

- [dot-files](#dot-files)
  - [Requirements](#requirements)
    - [MacOS](#macos)
    - [Ubuntu](#ubuntu)
  - [NeoVim](#neovim)
    - [MacOS <!-- {#nvim} -->](#macos-nvim)
    - [Ubuntu <!-- {#nvim} -->](#ubuntu-nvim)

## Requirements

### MacOS

1. Install Homebrew:
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

1. Install Git:
   `brew install git`

1. Install Oh-My-Zsh:

   `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

   > NOTE: Follow the instructions to set Zsh as the default shell.

### Ubuntu

1. Install required tools:
   `sudo apt install git curl ripgrep fd-find unzip build-essential -y`

1. Install Zsh:

   ```bash
   sudo apt install zsh -y
   chsh -s $(which zsh)
   ```

1. Install Oh-My-Zsh:

   `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

   > NOTE: Follow the instructions to set Zsh as the default shell.

## NeoVim

### MacOS <!-- {#nvim} -->

1. Install Homebrew:
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### Ubuntu <!-- {#nvim:w} -->

Install Required Tools first:
`sudo apt install git curl ripgrep fd-find unzip build-essential -y`

1. Ensure that your system has installed libfuse, if not, install it by running:

   - **Ubuntu 22.04:**

   ```bash
   sudo add-apt-repository universe
   sudo apt install libfuse2
   ```

   - **Ubuntu 24.04:**

   ```bash
   sudo add-apt-repository universe
   sudo apt install libfuse2t64
   ```

1. Run the shell script `nvim_linux.sh` to install NVim.

1. Create `~/.config` if it is not existed, by `mkdir -p ~/.config`

1. Create symlink to this repository for LazyVim:
   `ln -s ~/dot-files/nvim ~/.config/nvim`
