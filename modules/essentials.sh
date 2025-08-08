#!/bin/bash
# modules/utils.sh - Essential Utilities Installation

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[UTILS]${NC} $1"
}

# Install essential utilities
log_info "Installing essential utilities..."
sudo apt install -y \
    curl \
    wget \
    zip \
    unzip \
    tree \
    neofetch \
    build-essential \
    software-properties-common

log_info "✅ Essential utilities installed successfully"
log_info "Available: curl, wget, zip, unzip, tree, neofetch, build-essential"