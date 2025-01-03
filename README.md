# dot-files

Clone this repository under `~`

## NVim Installation

### Ubuntu

Install Required Tools first:
`sudo apt install git curl ripgrep fd-find unzip build-essential -y`

- Step 1: Ensure that your system has installed libfuse, if not, install it by running:
  - Ubuntu 22.04:
    `sudo add-apt-repository universe
sudo apt install libfuse2`
  - Ubuntu 24.04:
    `sudo add-apt-repository universe
sudo apt install libfuse2t64`
- Step 2: Run the shell script `nvim_linux.sh` to install NVim.
- Step 3: Create symlink to this repository for LazyVim:
  `ln -s ~/dot-files/nvim ~/.config/nvim`
