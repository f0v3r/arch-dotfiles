#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root. Run as a regular user with sudo privileges."
   exit 1
fi

OFFICIAL_PACKAGES=(
    wget
    curl
    zed
    ffmpeg
    micro
    lazygit
    eza
    bat
    mpv
    unp
    fzf
    btop
    chezmoi
    cmus
    cava
    fastfetch
    helix
    fish
    ghostty    
    tailscale
    noto-fonts
    noto-fonts-cjk
    noto-fonts-extra
    man-db
    man-pages
    iputils
    inetutils
    wl-clipboard
    tmux
    ripgrep
    nmap
    networkmanager
    bluez
    bluez-utils
    ttf-cascadia-mono-nerd
    7zip
    yazi
    obsidian
)

AUR_PACKAGES=(
    nitchrevived
    visual-studio-code-bin
    zen-browser-bin
    localsend-bin
    nerdfetch
    maplemono-nf
    xnviewmp
    rar
)

update_system() {
    log_info "Updating system..."
    sudo pacman -Syu --noconfirm
    log_success "System updated"
}

install_official_packages() {
    if [ ${#OFFICIAL_PACKAGES[@]} -eq 0 ]; then
        log_warning "No official packages to install"
        return
    fi
    
    log_info "Installing official packages..."
    for package in "${OFFICIAL_PACKAGES[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            log_warning "$package is already installed"
        else
            log_info "Installing $package..."
            sudo pacman -S --noconfirm "$package" || log_error "Failed to install $package"
        fi
    done
    log_success "Official packages installation complete"
}

install_yay() {
    if command -v yay &> /dev/null; then
        log_success "yay is already installed"
        return
    fi
    
    log_info "Installing yay AUR helper..."
    
    sudo pacman -S --needed --noconfirm git base-devel
    
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    
    log_success "yay installed successfully"
}

install_aur_packages() {
    if [ ${#AUR_PACKAGES[@]} -eq 0 ]; then
        log_warning "No AUR packages to install"
        return
    fi
    
    if ! command -v yay &> /dev/null; then
        log_error "yay is not installed. Cannot install AUR packages."
        return
    fi
    
    log_info "Installing AUR packages..."
    for package in "${AUR_PACKAGES[@]}"; do
        if yay -Qi "$package" &> /dev/null; then
            log_warning "$package is already installed"
        else
            log_info "Installing $package from AUR..."
            yay -S --noconfirm "$package" || log_error "Failed to install $package"
        fi
    done
    log_success "AUR packages installation complete"
}

install_flatpak_packages() {
    if [ ${#FLATPAK_PACKAGES[@]} -eq 0 ]; then
        log_warning "No Flatpak packages to install"
        return
    fi
    
    if ! command -v flatpak &> /dev/null; then
        log_info "Installing flatpak..."
        sudo pacman -S --noconfirm flatpak
    fi
    
    log_info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    log_info "Installing Flatpak packages..."
    for package in "${FLATPAK_PACKAGES[@]}"; do
        if flatpak list | grep -q "$package"; then
            log_warning "$package is already installed"
        else
            log_info "Installing $package from Flathub..."
            flatpak install -y flathub "$package" || log_error "Failed to install $package"
        fi
    done
    log_success "Flatpak packages installation complete"
}

change_shell_to_fish() {
    if ! command -v fish &> /dev/null; then
        log_error "Fish shell is not installed. Skipping shell change."
        return
    fi
    
    local fish_path=$(which fish)
    local current_shell=$(getent passwd "$USER" | cut -d: -f7)
    
    if [ "$current_shell" = "$fish_path" ]; then
        log_success "Shell is already set to fish"
        return
    fi
    
    log_info "Changing default shell to fish..."
    
    if ! grep -q "$fish_path" /etc/shells; then
        log_info "Adding fish to /etc/shells..."
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    chsh -s "$fish_path"
    
    log_success "Default shell changed to fish. Please log out and back in for changes to take effect."
}

enable_services() {
    log_info "Enabling NetworkManager service..."
    sudo systemctl enable NetworkManager.service
    sudo systemctl start NetworkManager.service
    log_success "NetworkManager enabled and started"
    
    log_info "Enabling Bluetooth service..."
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
    log_success "Bluetooth enabled and started"
}

install_rust() {
    if command -v rustc &> /dev/null; then
        log_success "Rust is already installed"
        return
    fi
    
    log_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    log_success "Rust installed successfully"
}

install_uv() {
    if command -v uv &> /dev/null; then
        log_success "uv is already installed"
        return
    fi
    
    log_info "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_success "uv installed successfully"
}

main() {
    log_info "Starting Arch Linux setup..."
    echo ""
    
    update_system
    echo ""
    
    install_official_packages
    echo ""
    
    if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
        install_yay
        echo ""
        install_aur_packages
        echo ""
    fi
    
    if [ ${#FLATPAK_PACKAGES[@]} -gt 0 ]; then
        install_flatpak_packages
        echo ""
    fi
    
    enable_services
    echo ""
    
    install_rust
    echo ""
    
    install_uv
    echo ""
    
    change_shell_to_fish
    echo ""
    
    log_success "Setup complete! You may need to reboot for some changes to take effect."
}

main
