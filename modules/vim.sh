#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[VIM]${NC} $1"; }
sudo apt install -y vim neovim
log_info "✅ Vim and Neovim installed successfully"
log_info "Launch with: vim or nvim"