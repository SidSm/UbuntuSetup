#!/bin/bash
# modules/rpi-imager.sh - Raspberry Pi Imager Installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[RPI-IMAGER]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[RPI-IMAGER]${NC} $1"
}

log_error() {
    echo -e "${RED}[RPI-IMAGER]${NC} $1"
}

# Check if Raspberry Pi Imager is already installed
if command -v rpi-imager >/dev/null 2>&1; then
    log_warn "Raspberry Pi Imager is already installed"
    log_info "✅ Raspberry Pi Imager installation verified"
    exit 0
fi

# Method 1: Try official .deb package (most reliable)
log_info "Downloading official Raspberry Pi Imager..."

# Try latest official .deb package
DEB_URL="https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb"

log_info "Downloading from: $DEB_URL"
if wget -O rpi-imager.deb "$DEB_URL"; then
    log_info "Installing Raspberry Pi Imager..."
    
    # Install the package
    if sudo dpkg -i rpi-imager.deb; then
        # Fix any dependency issues
        sudo apt-get install -f -y
        
        # Clean up
        rm -f rpi-imager.deb
        
        log_info "✅ Raspberry Pi Imager installed successfully via official .deb package"
        log_info "Launch with: rpi-imager"
        exit 0
    else
        log_warn "Package installation failed, fixing dependencies..."
        sudo apt-get install -f -y
        
        if command -v rpi-imager >/dev/null 2>&1; then
            rm -f rpi-imager.deb
            log_info "✅ Raspberry Pi Imager installed successfully after dependency fix"
            log_info "Launch with: rpi-imager"
            exit 0
        fi
    fi
    
    # Clean up failed .deb file
    rm -f rpi-imager.deb
fi

# Method 2: Try GitHub releases (alternative .deb)
log_warn "Official .deb failed, trying GitHub releases..."

# Get latest GitHub release
GITHUB_DEB_URL=$(curl -s https://api.github.com/repos/raspberrypi/rpi-imager/releases/latest | \
    grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4 | head -1)

if [[ -n "$GITHUB_DEB_URL" ]]; then
    log_info "Found GitHub release: $GITHUB_DEB_URL"
    if wget -O rpi-imager-github.deb "$GITHUB_DEB_URL"; then
        log_info "Installing from GitHub release..."
        
        if sudo dpkg -i rpi-imager-github.deb; then
            sudo apt-get install -f -y
            rm -f rpi-imager-github.deb
            
            log_info "✅ Raspberry Pi Imager installed successfully via GitHub release"
            log_info "Launch with: rpi-imager"
            exit 0
        fi
        
        rm -f rpi-imager-github.deb
    fi
fi

# Method 3: Try Snap
log_warn "GitHub installation failed, trying Snap..."
if sudo snap install rpi-imager 2>/dev/null; then
    log_info "✅ Raspberry Pi Imager installed successfully via Snap"
    log_info "Launch with: rpi-imager"
    exit 0
fi

# Method 4: Try Flatpak
if command -v flatpak >/dev/null 2>&1; then
    log_warn "Snap installation failed, trying Flatpak..."
    if flatpak install -y flathub org.raspberrypi.rpi-imager 2>/dev/null; then
        # Create symlink for command line access
        mkdir -p ~/.local/bin
        cat > ~/.local/bin/rpi-imager << 'EOF'
#!/bin/bash
flatpak run org.raspberrypi.rpi-imager "$@"
EOF
        chmod +x ~/.local/bin/rpi-imager
        
        log_info "✅ Raspberry Pi Imager installed successfully via Flatpak"
        log_info "Launch with: rpi-imager or from Applications menu"
        exit 0
    fi
fi

# Method 5: Try AppImage (if available)
log_warn "Flatpak installation failed, trying AppImage..."

# Check for AppImage releases
APPIMAGE_URL=$(curl -s https://api.github.com/repos/raspberrypi/rpi-imager/releases/latest | \
    grep "browser_download_url.*AppImage" | cut -d '"' -f 4 | head -1)

if [[ -n "$APPIMAGE_URL" ]]; then
    log_info "Found AppImage: $APPIMAGE_URL"
    if wget -O rpi-imager.AppImage "$APPIMAGE_URL"; then
        chmod +x rpi-imager.AppImage
        sudo mv rpi-imager.AppImage /opt/
        sudo ln -sf /opt/rpi-imager.AppImage /usr/local/bin/rpi-imager
        
        # Create desktop entry
        mkdir -p ~/.local/share/applications
        cat > ~/.local/share/applications/rpi-imager.desktop << EOF
[Desktop Entry]
Name=Raspberry Pi Imager
Comment=Raspberry Pi Imaging Utility
Exec=/opt/rpi-imager.AppImage
Icon=rpi-imager
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=raspberry;pi;imager;sd;card;flash;
EOF
        
        log_info "✅ Raspberry Pi Imager installed successfully via AppImage"
        log_info "Launch with: rpi-imager"
        exit 0
    fi
fi

# Method 6: Try Ubuntu repositories (might be available in newer versions)
log_warn "AppImage installation failed, checking Ubuntu repositories..."
sudo apt update
if sudo apt install -y rpi-imager 2>/dev/null; then
    log_info "✅ Raspberry Pi Imager installed successfully via Ubuntu repositories"
    log_info "Launch with: rpi-imager"
    exit 0
fi

# Method 7: Manual installation instructions
log_error "❌ All automatic installation methods failed"
echo ""
log_info "Manual installation options:"
echo "1. Download from official website:"
echo "   https://www.raspberrypi.com/software/"
echo ""
echo "2. Download .deb package directly:"
echo "   https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb"
echo ""
echo "3. Install via command line:"
echo "   wget https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb"
echo "   sudo dpkg -i imager_latest_amd64.deb"
echo "   sudo apt-get install -f"
echo ""
echo "4. Build from source:"
echo "   https://github.com/raspberrypi/rpi-imager"

exit 1