#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[HTOP]${NC} $1"; }
sudo apt install -y htop
log_info "✅ htop installed successfully"
log_info "Launch with: htop"