#!/bin/bash
# modules/vscode.sh - Visual Studio Code Installation

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[VSCODE]${NC} $1"
}

# Add Microsoft GPG key and repository
log_info "Adding Microsoft repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Update package list and install
log_info "Installing Visual Studio Code..."
sudo apt update
sudo apt install -y code

# Clean up
rm -f packages.microsoft.gpg

log_info "✅ Visual Studio Code installed successfully"
log_info "Launch with: code"
