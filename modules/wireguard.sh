#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[WIREGUARD]${NC} $1"; }
sudo apt install -y wireguard
log_info "✅ Wireguard installed successfully"
log_info "Use with utility: wg-quick"