#!/bin/bash
# modules/prusaslicer.sh - PrusaSlicer Installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[PRUSASLICER]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[PRUSASLICER]${NC} $1"
}

log_error() {
    echo -e "${RED}[PRUSASLICER]${NC} $1"
}

# Check if PrusaSlicer is already installed
if command -v prusa-slicer >/dev/null 2>&1; then
    log_warn "PrusaSlicer appears to be already installed"
    log_info "✅ PrusaSlicer installation verified"
    exit 0
fi

# Method 1: Try Snap
log_warn "Flatpak installation failed, trying Snap..."
if sudo snap install prusa-slicer 2>/dev/null; then
    log_info "✅ PrusaSlicer installed successfully via Snap"
    log_info "Launch with: prusa-slicer"
    exit 0
fi

# Method 2: Try Ubuntu PPA (if available)
log_warn "Snap installation failed, checking for Ubuntu packages..."
sudo apt update
if sudo apt install -y prusaslicer 2>/dev/null; then
    log_info "✅ PrusaSlicer installed successfully via APT"
    log_info "Launch with: prusaslicer"
    exit 0
fi

# Method 3: Try building from source (Ubuntu packages)
log_warn "Snap installation failed, trying to install dependencies for manual installation..."
log_info "Installing build dependencies..."

# Install dependencies
sudo apt update
sudo apt install -y \
    git \
    cmake \
    build-essential \
    pkg-config \
    libtbb-dev \
    libwxgtk3.0-gtk3-dev \
    libboost-dev \
    libboost-regex-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libboost-log-dev \
    libboost-locale-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libnlopt-dev \
    libopenvdb-dev \
    libudev-dev

log_info "Dependencies installed. For manual compilation, visit:"
log_info "https://github.com/prusa3d/PrusaSlicer/blob/master/doc/How%20to%20build%20-%20Linux%20et%20al.md"

# Method 5: Manual download fallback
log_warn "Providing manual installation instructions..."
log_info "You can manually download PrusaSlicer from:"
log_info "https://github.com/prusa3d/PrusaSlicer/releases/latest"
log_info "Look for the Linux AppImage file"

log_error "❌ Automatic installation failed"
log_info "Manual installation recommended from: https://www.prusa3d.com/prusaslicer/"
exit 1