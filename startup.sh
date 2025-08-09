#!/bin/bash

# Startup script for a new computer

# Made for ubuntu linux

# chmod +x startup.sh
# ./startup.sh


REPO_NAME="UbuntuSetup"
RESET_FLAG="$2"
KEY_DIR="~/.ssh"
KEY_NAME="${REPO_NAME}"
SSH_CONFIG="$HOME/.ssh/config"
REPO_URL="SidSm/${REPO_NAME}"
CLONE_DIR="$HOME/Zdrojaky"    


echo "============================================================="
echo "Welcome to your new machine, lets make it here feel like home"
echo "============================================================="
echo ""
echo "Downloading UbuntuSetup scripts..."

# Function to clone repository
clone_repository() {
    echo "Creating Zdrojaky directory..."
    mkdir -p "$CLONE_DIR"
    
    echo "Cloning repository into $CLONE_DIR/$REPO_NAME..."
    cd "$CLONE_DIR"
    if git clone https://github.com/$REPO_URL; then
        echo "✅ Repository cloned successfully!"
        
        cd "$REPO_NAME"
        echo ""
        echo "Available branches:"
        git branch -r
        echo ""
        echo "Current branch: $(git branch --show-current)"
        echo ""
        echo "To switch to your site branch, use:"
        echo "cd $CLONE_DIR/$REPO_NAME"
        echo "git checkout $REPO_NAME-prod"
        echo ""
        return 0
    else
        echo "❌ Failed to clone repository."
        return 1
    fi
}

# Check if Git is installed
if ! command -v git >/dev/null 2>&1; then
    log_warn "Git is not installed. Installing Git first..."
    sudo apt update
    sudo apt install -y git
    if ! command -v git >/dev/null 2>&1; then
        log_warn "❌ Failed to install Git. SSH key will be generated but Git config will be skipped."
        SKIP_GIT_CONFIG=true
    else
        log_info "✅ Git installed successfully"

    fi

    # Get user information
    echo -ne "${BLUE}Enter your name for Git/SSH: ${NC}"
    read -r user_name
    echo -ne "${BLUE}Enter your email (GitHub email recommended): ${NC}"
    read -r user_email

    # Configure Git with user info
    log_info "Configuring Git with your information..."
    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
fi

# Test connection and clone loop
if clone_repository; then
    echo ""
    echo "🎉 SUCCESS! Setup complete for $REPO_NAME"
    echo "Repository location: $CLONE_DIR/$REPO_NAME"
    break
else
    echo ""
    echo "SSH works but cloning failed. This might be a temporary issue."
    echo "Maybe you want to delete the repo and clone it again?"
fi

echo ""
echo "=========================================="
echo "🎉 SETUP COMPLETE!"
echo "=========================================="
echo "UbuntuSetup repository cloned to: $CLONE_DIR/$REPO_NAME"
echo "SSH host alias: github-$REPO_NAME"
echo "Private key: $KEY_DIR/$KEY_NAME"
echo "Public key: $KEY_DIR/$KEY_NAME.pub"
echo ""
echo "Next steps:"
echo "1. cd $CLONE_DIR/$REPO_NAME"
echo "2. git checkout $REPO_NAME  # or your branch name"
echo "3. bash ./setup_apps.sh     # or run individual modules"