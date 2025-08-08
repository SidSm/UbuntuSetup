#!/bin/bash
# modules/nodejs.sh - Node.js and npm Installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[NODEJS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[NODEJS]${NC} $1"
}

# Check if Node.js is already installed
if command -v node >/dev/null 2>&1; then
    current_version=$(node --version)
    log_warn "Node.js is already installed ($current_version)"
    log_info "✅ Node.js installation verified"
    exit 0
fi

# Install Node.js LTS via NodeSource repository
log_info "Adding NodeSource repository..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

log_info "Installing Node.js and npm..."
sudo apt install -y nodejs

# Verify installation
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    node_version=$(node --version)
    npm_version=$(npm --version)
    log_info "✅ Node.js $node_version installed successfully"
    log_info "✅ npm $npm_version installed successfully"
    
    # Install common global packages
    log_info "Installing common global packages..."
    npm install -g \
        yarn \
        pnpm \
        @vue/cli \
        create-react-app \
        typescript \
        ts-node \
        nodemon \
        pm2
    
    log_info "Global packages installed: yarn, pnpm, @vue/cli, create-react-app, typescript, ts-node, nodemon, pm2"
else
    log_warn "❌ Node.js installation failed"
    exit 1
fi