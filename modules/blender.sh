#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}[BLENDER]${NC} $1"; }
sudo apt install -y blender
log_info "✅ Blender installed successfully"
log_info "Launch with: blender"