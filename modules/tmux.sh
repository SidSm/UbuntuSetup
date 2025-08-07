#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[TMUX]${NC} $1"; }
sudo apt install -y tmux
log_info "✅ tmux installed successfully"
log_info "Launch with: tmux"