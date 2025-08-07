#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[TWEAKS]${NC} $1"; }
sudo apt install -y gnome-shell-extension-manager
log_info "✅ GNOME Extensions installed successfully"
