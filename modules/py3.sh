#!/bin/bash
# modules/python.sh - Python3 Environment Setup

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[PYTHON]${NC} $1"
}

# Install Python3 and essential packages
log_info "Installing Python3 environment..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    build-essential \
    libssl-dev \
    libffi-dev

# Upgrade pip
log_info "Upgrading pip..."
python3 -m pip install --user --upgrade pip

# Install common Python packages
log_info "Installing common Python packages..."
python3 -m pip install --user \
    virtualenv \
    pipx \
    black \
    flake8 \
    requests \
    numpy

# Add pipx to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    log_info "Added ~/.local/bin to PATH in ~/.bashrc"
fi

# Verify installation
python_version=$(python3 --version 2>&1)
pip_version=$(python3 -m pip --version 2>&1 | cut -d' ' -f2)

log_info "✅ Python3 environment installed successfully"
log_info "Python: $python_version"
log_info "pip: $pip_version"
log_info "Create virtual env with: python3 -m venv myenv"
log_info "Activate with: source myenv/bin/activate"