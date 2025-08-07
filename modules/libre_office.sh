#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[LIBREOFFICE]${NC} $1"; }
sudo apt install -y libreoffice
log_info "✅ LibreOffice installed successfully"
log_info "Launch from Applications menu"