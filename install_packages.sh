#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "################################################################"
echo "##          Arch Linux Post-Install Setup Script            ##"
echo "################################################################"
echo
echo "This script will install the following packages:"
echo "From official repositories (pacman):"
echo "  - lf (file manager)"
echo "  - git (version control)"
echo "  - firefox (web browser)"
echo "  - alacritty (terminal - listed as 'comes installed' but ensuring)"
echo "  - nitrogen (wallpaper setter)"
echo "  - rofi (launcher)"
echo "  - polybar (status bar)"
echo "  - nm-connection-editor (network manager GUI)"
echo "  - vlc (media player)"
echo "  - base-devel (needed for building AUR packages)"
echo
echo "From AUR (using yay):"
echo "  - yay (AUR helper - will be installed first)"
echo "  - visual-studio-code-bin (VSCode)"
echo "  - brightness-controller-git (brightness control)"
echo "  - spotify (music streaming)"
echo
echo "You will be prompted for your sudo password."
echo
read -p "Do you want to proceed with the installation? (y/N): " confirm
if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
    echo "Installation aborted by user."
    exit 0
fi

# --- Update System First (Optional but Recommended) ---
echo
echo ">>> Updating system packages..."
sudo pacman -Syu --noconfirm

# --- Install yay (AUR Helper) ---
echo
echo ">>> Checking for yay..."
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    # Install dependencies for building yay
    sudo pacman -S --needed --noconfirm git base-devel go

    # Create a temporary directory for building yay
    tmp_dir=$(mktemp -d)
    echo "Cloning yay into temporary directory: $tmp_dir"
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    
    current_dir=$(pwd)
    cd "$tmp_dir/yay"
    
    echo "Building and installing yay..."
    makepkg -si --noconfirm
    
    cd "$current_dir" # Go back to original directory
    rm -rf "$tmp_dir" # Clean up temporary directory
    echo "yay installed successfully."
else
    echo "yay is already installed."
fi

# --- Install Packages from Official Repositories ---
echo
echo ">>> Installing packages from official repositories (pacman)..."
sudo pacman -S --needed --noconfirm \
    lf \
    git \
    firefox \
    alacritty \
    nitrogen \
    rofi \
    polybar \
    nm-connection-editor \
    vlc

echo "Pacman packages installation complete."

# --- Install Packages from AUR using yay ---
echo
echo ">>> Installing packages from AUR (yay)..."
# Note: `yay` will ask for sudo password if needed for installing dependencies
# The `--noconfirm` here applies to yay's prompts, not sudo.
# visual-studio-code-bin is generally preferred over compiling from source for VSCode.
yay -S --needed --noconfirm \
    visual-studio-code-bin \
    brightness-controller-git \
    spotify

echo "AUR packages installation complete."

echo
echo "################################################################"
echo "##                  Installation Finished!                  ##"
echo "################################################################"
echo
echo "Don't forget to configure your new tools (polybar, rofi, nitrogen, etc.)."
echo "You might need to log out and log back in for some changes to take effect."

exit 0
