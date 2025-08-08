#!/bin/bash
# modules/ssh-github.sh - SSH Key Generation and GitHub Setup

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[SSH-GITHUB]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[SSH-GITHUB]${NC} $1"
}
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

# Check if SSH key already exists
if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
    log_warn "SSH key already exists. Skipping key generation."
    if [[ -f ~/.ssh/id_ed25519.pub ]]; then
        existing_key=$(cat ~/.ssh/id_ed25519.pub)
    elif [[ -f ~/.ssh/id_rsa.pub ]]; then
        existing_key=$(cat ~/.ssh/id_rsa.pub)
    fi
    
    log_info "Your existing public key:"
    echo "$existing_key"
    
    # Copy to clipboard if possible
    if command -v xclip >/dev/null 2>&1; then
        echo "$existing_key" | xclip -selection clipboard
        log_info "✅ Public key copied to clipboard!"
    elif command -v xsel >/dev/null 2>&1; then
        echo "$existing_key" | xsel --clipboard --input
        log_info "✅ Public key copied to clipboard!"
    else
        log_warn "Install xclip or xsel to auto-copy keys to clipboard"
    fi
    exit 0
fi

# Generate SSH key
log_info "Generating SSH key..."
ssh-keygen -t ed25519 -C "$user_email" -f ~/.ssh/id_ed25519 -N ""

# Start SSH agent and add key
log_info "Adding SSH key to SSH agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display the public key
log_info "Your new SSH public key:"
cat ~/.ssh/id_ed25519.pub

# Copy to clipboard if possible
if command -v xclip >/dev/null 2>&1; then
    cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
    log_info "✅ Public key copied to clipboard!"
elif command -v xsel >/dev/null 2>&1; then
    cat ~/.ssh/id_ed25519.pub | xsel --clipboard --input
    log_info "✅ Public key copied to clipboard!"
else
    # Install xclip for clipboard functionality
    sudo apt install -y xclip
    cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
    log_info "✅ Public key copied to clipboard!"
fi

# Create SSH config for GitHub
log_info "Creating SSH config for GitHub..."
mkdir -p ~/.ssh
cat >> ~/.ssh/config << EOF

# GitHub configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF

# Set proper permissions
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh

log_info "🔑 SSH setup complete!"
if [[ "$SKIP_GIT_CONFIG" == true ]]; then
    log_warn "⚠️  Git configuration was skipped. Run 'git config --global user.name \"Your Name\"' and 'git config --global user.email \"your@email.com\"' manually."
fi
echo ""
echo "Next steps:"
echo "1. Go to GitHub.com → Settings → SSH and GPG keys"
echo "2. Click 'New SSH key'"
echo "3. Paste the key (already copied to clipboard)"
echo "4. Give it a title (e.g., 'Ubuntu Desktop')"
echo "5. Click 'Add SSH key'"
echo "6. When you are ready, click Enter"
echo ""
# Test connection and clone loop
while true; do
    echo ""
    echo "🔄 Testing SSH connection..."
    
    if test_ssh_connection; then
            echo ""
            echo "🎉 SUCCESS! GitHub setup complete"
            break
    else
        echo ""
        echo "❌ SSH connection failed. Possible issues:"
        echo "   - The key not added to GitHub yet"
        echo "   - 'Allow write access' not checked"
        echo "   - Key not properly configured"
        echo ""
        echo "Public key (copy this to GitHub):"
        echo "-----------------------------------"
        cat "$KEY_DIR/$KEY_NAME.pub"
        echo "-----------------------------------"
        echo ""
        echo "GitHub URL: https://github.com/settings/keys"
        echo ""
        wait_for_user "Please check your GitHub SSH key setup and try again."
    fi
done

echo ""
echo "=========================================="
echo "🎉 SETUP COMPLETE!"
echo "=========================================="