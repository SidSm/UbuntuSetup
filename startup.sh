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
CLONE_DIR="$HOME/Desktop/Zdrojaky"    


echo "============================================================="
echo "Welcome to your new machine, lets make it here feel like home"
echo "============================================================="

# Function to wait for user input with quit option
wait_for_user() {
    local message="$1"
    while true; do
        echo ""
        echo "$message"
        echo "Press Enter to continue, or 'q' to quit..."
        read -r user_input
        
        if [ "$user_input" = "q" ] || [ "$user_input" = "Q" ]; then
            echo "Script cancelled by user."
            exit 0
        elif [ -z "$user_input" ]; then
            break
        else
            echo "Invalid input. Press Enter to continue or 'q' to quit."
        fi
    done
}

# Function to test SSH connection
test_ssh_connection() {
    echo "Testing SSH connection to GitHub..."
    # Remove BatchMode to allow key authentication, capture output
    local ssh_output
    ssh_output=$(ssh -T -o ConnectTimeout=10 -o StrictHostKeyChecking=no git@github-$REPO_NAME 2>&1)
    local ssh_exit_code=$?
    
    # GitHub SSH returns exit code 1 for successful auth (this is normal)
    # Check if the output contains success message
    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        echo "✅ SSH connection successful!"
        echo "Response: $ssh_output"
        return 0
    else
        echo "❌ SSH connection failed."
        echo "Output: $ssh_output"
        return 1
    fi
}

# Function to remove existing keys and config
remove_existing_keys() {
    echo "Removing existing keys and SSH config for $REPO_NAME..."
    
    # Remove private and public keys
    if [ -f "$KEY_DIR/$KEY_NAME" ]; then
        rm -f "$KEY_DIR/$KEY_NAME"
        echo "Removed private key: $KEY_DIR/$KEY_NAME"
    fi
    
    if [ -f "$KEY_DIR/$KEY_NAME.pub" ]; then
        rm -f "$KEY_DIR/$KEY_NAME.pub"
        echo "Removed public key: $KEY_DIR/$KEY_NAME.pub"
    fi
    
    # Remove SSH config entry
    if [ -f "$SSH_CONFIG" ]; then
        # Create a temp file without the config block for this site
        awk -v host="Host github-$REPO_NAME" '
        $0 == host {skip=1; next}
        skip && /^Host / {skip=0}
        !skip {print}
        ' "$SSH_CONFIG" > "$SSH_CONFIG.tmp" && mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
        echo "Removed SSH config entry for github-$REPO_NAME"
    fi
}

# Function to create SSH keys and config
create_keys_and_config() {
    echo "Creating keys directory..."
    mkdir -p "$KEY_DIR"
    
    # Generate SSH key
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$REPO_NAME" -f "$KEY_DIR/$KEY_NAME" -N ""
    
    # Create SSH config directory
    echo "Creating SSH config..."
    mkdir -p ~/.ssh
    
    # Add SSH config entry
    echo "Configuring SSH..."
    cat >> "$SSH_CONFIG" << EOF

Host github-$REPO_NAME
    HostName github.com
    User git
    IdentityFile $KEY_DIR/$KEY_NAME
    IdentitiesOnly yes
EOF
    
    # Set proper permissions
    echo "Setting file permissions..."
    chmod 600 "$KEY_DIR/$KEY_NAME"
    chmod 644 "$KEY_DIR/$KEY_NAME.pub"
    chmod 600 "$SSH_CONFIG"
    
    echo "✅ SSH key and config created successfully!"
}

# Function to show GitHub setup instructions
show_github_instructions() {
    echo ""
    echo "=========================================="
    echo "COPY THIS PUBLIC KEY TO GITHUB:"
    echo "=========================================="
    echo ""
    cat "$KEY_DIR/$KEY_NAME.pub"
    echo ""
    echo "=========================================="
    echo "GITHUB SETUP STEPS:"
    echo "=========================================="
    echo "1. Go to: https://github.com/$REPO_URL/settings/keys"
    echo "2. Click 'Add deploy key'"
    echo "3. Title: 'Windows Server - $REPO_NAME'"
    echo "4. Paste the key above"
    echo "5. ✅ CHECK 'Allow write access'"
    echo "6. Click 'Add key'"
    echo ""
}

# Function to clone repository
clone_repository() {
    echo "Creating Zdrojaky directory..."
    mkdir -p "$CLONE_DIR"
    
    echo "Cloning repository into $CLONE_DIR/$REPO_NAME..."
    cd "$CLONE_DIR"
    
    if git clone git@github-$REPO_NAME:$REPO_URL.git "$REPO_NAME"; then
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


if [ -f "$KEY_DIR/$KEY_NAME" ] && [ -f "$KEY_DIR/$KEY_NAME.pub" ]; then
    echo "🔍 Existing keys found for $REPO_NAME"
    echo "Files found:"
    echo "- Private key: $KEY_DIR/$KEY_NAME"
    echo "- Public key:  $KEY_DIR/$KEY_NAME.pub"
    echo ""
    echo "⏩ Skipping key generation, going directly to clone test..."
else
    echo "📝 No existing keys found. Creating new ones..."
    create_keys_and_config
    show_github_instructions
    wait_for_user "Please add the public key to GitHub as shown above."
fi

# Test connection and clone loop
while true; do
    echo ""
    echo "🔄 Testing SSH connection and attempting to clone..."
    
    if test_ssh_connection; then
        if clone_repository; then
            echo ""
            echo "🎉 SUCCESS! Setup complete for $REPO_NAME"
            echo "Repository location: $CLONE_DIR/$REPO_NAME"
            break
        else
            echo ""
            echo "SSH works but cloning failed. This might be a temporary issue."
			echo "Maybe you want to delete the repo and clone it again?"
            wait_for_user "Try again?"
        fi
    else
        echo ""
        echo "❌ SSH connection failed. Possible issues:"
        echo "   - Deploy key not added to GitHub yet"
        echo "   - 'Allow write access' not checked"
        echo "   - Key not properly configured"
        echo ""
        echo "Public key (copy this to GitHub):"
        echo "-----------------------------------"
        cat "$KEY_DIR/$KEY_NAME.pub"
        echo "-----------------------------------"
        echo ""
        echo "GitHub URL: https://github.com/$REPO_URL/settings/keys"
        echo ""
        wait_for_user "Please check your GitHub deploy key setup and try again."
    fi
done


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