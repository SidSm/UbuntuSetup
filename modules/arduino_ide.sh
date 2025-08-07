#!/bin/bash
# modules/arduino.sh - Arduino IDE Installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[ARDUINO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[ARDUINO]${NC} $1"
}

# Get latest Arduino IDE download URL
log_info "Fetching latest Arduino IDE version..."
ARDUINO_URL=$(curl -s https://api.github.com/repos/arduino/arduino-ide/releases/latest | \
    grep "browser_download_url.*Linux_64bit.zip" | cut -d '"' -f 4)

if [[ -z "$ARDUINO_URL" ]]; then
    log_warn "❌ Could not fetch Arduino IDE download URL"
    exit 1
fi

# Download and extract Arduino IDE
log_info "Downloading Arduino IDE..."
wget -O arduino-ide.zip "$ARDUINO_URL"

log_info "Extracting Arduino IDE..."
unzip -q arduino-ide.zip

# Move to /opt and create symlink
log_info "Installing Arduino IDE..."
sudo mv arduino-ide_* /opt/arduino-ide
sudo ln -sf /opt/arduino-ide/arduino-ide /usr/local/bin/arduino-ide

# Create desktop entry
log_info "Creating desktop entry..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/arduino-ide.desktop << EOF
[Desktop Entry]
Name=Arduino IDE
Comment=Arduino IDE
Exec=/opt/arduino-ide/arduino-ide
Icon=/opt/arduino-ide/resources/app/resources/icons/512x512.png
Terminal=false
Type=Application
Categories=Development;Electronics;
StartupWMClass=Arduino IDE
EOF

# Add user to dialout group for serial access
log_info "Adding user to dialout group..."
sudo usermod -aG dialout $USER

# Set the permissions
sudo chown root:root /opt/arduino-ide/chrome-sandbox
sudo chmod 4755 /opt/arduino-ide/chrome-sandbox

# Clean up
rm -f arduino-ide.zip

log_info "✅ Arduino IDE installed successfully"
log_info "Launch with: arduino-ide"
log_warn "⚠️  You may need to log out and back in for serial port access"