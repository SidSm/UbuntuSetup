#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[VLC]${NC} $1"; }
sudo apt install -y vlc
log_info "✅ VLC Media Player installed successfully"
log_info "Launch with: vlc"