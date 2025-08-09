# Ubuntu Fresh Install Setup Script 🚀

A comprehensive, modular Ubuntu setup script that automates the installation of essential development tools, applications, and configurations. Perfect for quickly setting up a new Ubuntu system with all your favorite tools.

## ✨ Features

- **🎯 Interactive Selection** - Choose exactly what you want to install
- **🧩 Modular Architecture** - Each app has its own installation module
- **🛡️ Error Handling** - Detailed success/failure reporting
- **🔑 SSH & GitHub Setup** - Automated SSH key generation and Git configuration
- **🖼️ Custom Wallpapers** - Download and set wallpapers from your GitHub repo
- **📊 Installation Reports** - Clear summary of what succeeded and failed

## 🚀 Quick Start

### Setup git and clone the repo 
```bash
curl -fsSL https://raw.githubusercontent.com/SidSm/UbuntuSetup/master/startup.sh | bash
```

### Setup git and add SSH keys to GitHub
```bash
curl -fsSL https://raw.githubusercontent.com/SidSm/UbuntuSetup/master/git_conf.sh | bash
```

### Download and Inspect First (Recommended)
```bash
wget https://raw.githubusercontent.com/SidSm/ubuntu-setup/main/setup.sh
chmod +x setup.sh
./setup.sh
```

## 📦 Available Applications

### 🔧 Development Tools
- **Git** - Version control system
- **Visual Studio Code** - Code editor with extensions pack
- **Python3** - Python environment with pip, venv, and common packages
- **Node.js & npm** - JavaScript runtime with global packages
- **Docker** - Containerization platform with Docker Compose
- **Arduino IDE** - Arduino development environment
- **Essential Utilities** - curl, wget, zip, tree, htop, build-essential

### 🌐 Browsers
- **Brave Browser** - Privacy-focused browser
- **Firefox** - Open-source browser (+ Developer Edition option)

### 💰 Cryptocurrency & Hardware
- **Trezor Suite** - Hardware wallet interface
- **Electrum Wallet** - Bitcoin wallet
- **Raspberry Pi Imager** - SD card imaging utility

### 🎨 Multimedia & Creativity
- **Blender** - 3D creation suite
- **GIMP** - Image editor
- **VLC Media Player** - Media player
- **OBS Studio** - Screen recording and streaming

### 💬 Communication
- **Telegram Desktop** - Messaging app
- **Discord** - Voice, video, and text chat

### ⚙️ System Utilities
- **tmux** - Terminal multiplexer
- **GNOME Tweaks** - System customization
- **htop** - System monitor
- **Vim & Neovim** - Text editors

### 📄 Office & Productivity
- **LibreOffice** - Office suite

### 🔑 SSH & GitHub Integration
- **Automated SSH key generation** (ED25519)
- **Git configuration** with user credentials
- **SSH agent setup**
- **GitHub integration** with step-by-step instructions

### 🖼️ Wallpaper Setup
- **GitHub wallpaper integration** - Download and set wallpapers from your repo
- **Multi-desktop environment support** (GNOME, XFCE, LXDE)
- **Interactive wallpaper selection**

## 🏗️ Modular Architecture

Each application is installed via its own module for better maintainability:

```
ubuntu-setup/
├── setup.sh                    # Main orchestrator script
├── modules/
│   ├── ssh-github.sh           # SSH + Git + GitHub setup
│   ├── vscode.sh               # Visual Studio Code
│   ├── vscode-extensions.sh    # VS Code extensions
│   ├── python.sh               # Python3 environment
│   ├── docker.sh               # Docker + Docker Compose
│   ├── nodejs.sh               # Node.js + npm
│   ├── telegram.sh             # Telegram (multiple fallbacks)
│   ├── wallpaper.sh            # GitHub wallpaper setup
│   └── ...                     # Other modules
└── README.md
```

### Install Individual Modules
```bash
# Install just Docker:
curl -fsSL https://raw.githubusercontent.com/SidSm/ubuntu-setup/main/modules/docker.sh | bash

# Install SSH setup:
curl -fsSL https://raw.githubusercontent.com/SidSm/ubuntu-setup/main/modules/ssh-github.sh | bash

# Install VS Code extensions:
curl -fsSL https://raw.githubusercontent.com/SidSm/ubuntu-setup/main/modules/vscode-extensions.sh | bash
```

## 🎯 VS Code Extensions

The VS Code extensions module installs essential extensions for:

- **Python Development** - Python, Black formatter, Flake8, Pylint
- **C/C++ Development** - C/C++ tools, CMake integration
- **Embedded Development** - PlatformIO for Arduino/ESP32
- **Docker Development** - Docker tools and Dev Containers
- **AI Assistance** - Codeium AI coding assistant

## 🛡️ Error Handling & Reporting

The script features comprehensive error handling:

```
==================================================
📊 INSTALLATION REPORT
==================================================

✅ SUCCESSFUL INSTALLATIONS (12):
  ✓ Git
  ✓ Visual Studio Code
  ✓ Python3 Environment
  ✓ Docker
  ✓ SSH & GitHub Setup
  ...

❌ FAILED INSTALLATIONS (2):
  ✗ Telegram Desktop
  ✗ Discord

💡 You can manually install failed applications later or re-run the script.
==================================================
```

## 🔑 SSH & GitHub Setup

The SSH module automatically:

1. **Checks for existing keys** - Won't overwrite existing SSH keys
2. **Installs Git** if not present
3. **Generates ED25519 SSH key** (most secure)
4. **Configures Git** with your name and email
5. **Sets up SSH agent** and adds the key
6. **Copies public key to clipboard**
7. **Provides GitHub setup instructions**

### Usage
```bash
# The script will prompt for:
Enter your name for Git/SSH: John Doe
Enter your email (GitHub email recommended): john@example.com

# Then provides instructions:
Next steps:
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click 'New SSH key'
3. Paste the key (already copied to clipboard)
4. Give it a title (e.g., 'Ubuntu Desktop')
5. Click 'Add SSH key'

Test your connection with: ssh -T git@github.com
```

## 🖼️ Wallpaper Setup

Set custom wallpapers from your GitHub repository:

### Repository Structure
```
your-wallpapers-repo/
├── sunset-mountain.jpg
├── abstract-blue.png
├── nature-forest.jpg
└── README.md
```

### Usage
```bash
# During setup, you'll be prompted:
Enter your GitHub username: yourusername
Enter your wallpapers repository name: my-wallpapers

# Then choose from available wallpapers:
Available wallpapers:
 1. sunset-mountain.jpg
 2. abstract-blue.png
 3. nature-forest.jpg

Enter the wallpaper filename (or number from list): 2
```

## 💻 System Requirements

- **Ubuntu 20.04+** (or Ubuntu-based distributions)
- **Internet connection** for downloads
- **sudo privileges** for system packages

## 🤝 Contributing

1. Fork the repository
2. Create a new module in the `modules/` directory
3. Follow the existing module structure:
   ```bash
   #!/bin/bash
   # modules/yourapp.sh - Your App Installation
   
   GREEN='\033[0;32m'; NC='\033[0m'
   log_info() { echo -e "${GREEN}[YOURAPP]${NC} $1"; }
   
   # Installation logic here
   log_info "✅ Your App installed successfully"
   ```
4. Add the module to the main `setup.sh` script
5. Test your module thoroughly
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This script modifies system packages and configurations. While tested on Ubuntu systems, please:

- **Review the code** before running on production systems
- **Test in a VM** if you're unsure
- **Backup important data** before running

## 🆘 Troubleshooting

### Common Issues

**VS Code extensions fail to install:**
```bash
# Make sure VS Code is installed first
code --version

# Install extensions manually:
code --install-extension ms-python.python
```

**Docker permission errors:**
```bash
# Log out and back in, or reboot after Docker installation
# Or temporarily use:
newgrp docker
```

**SSH key already exists:**
```bash
# The script will detect and display existing keys
# Manual check:
ls -la ~/.ssh/
```

### Getting Help

1. Check the installation report for specific failures
2. Run individual modules to isolate issues
3. Open an issue on GitHub with error details

## 🎉 Post-Installation

After running the script:

1. **Reboot your system** for all changes to take effect
2. **Test SSH connection**: `ssh -T git@github.com`
3. **Verify Docker**: `docker --version && docker compose version`
4. **Check VS Code extensions**: Open VS Code and verify extensions are loaded
5. **Configure applications** according to your preferences

---

**Made with ❤️ for the Ubuntu community**

*Simplifying Ubuntu setup, one script at a time.*