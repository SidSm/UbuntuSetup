#!/bin/bash

# Ubuntu Fresh Install Setup Script - Dynamic Module Discovery
# Run with: curl -fsSL https://raw.githubusercontent.com/yourusername/ubuntu-setup/main/setup.sh | bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Arrays to track installation results
declare -a SUCCESSFUL_INSTALLS=()
declare -a FAILED_INSTALLS=()
declare -A MODULE_SELECTIONS=()

# Local modules directory
MODULES_DIR="$(dirname "$0")/modules"
if [[ ! -d "$MODULES_DIR" ]]; then
    MODULES_DIR="./modules"
fi

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${CYAN}${1}${NC}"
}

ask_install() {
    local module_name="$1"
    local display_name="$2"
    local category="$3"
    local default="${4:-n}"
    local prompt
    
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    echo -ne "${BLUE}Install ${display_name}? ${prompt}: ${NC}"
    read -r response
    
    # Use default if no response
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    case "$response" in
        [Yy]* ) 
            MODULE_SELECTIONS["$module_name"]="true"
            return 0 
            ;;
        * ) 
            MODULE_SELECTIONS["$module_name"]="false"
            return 1 
            ;;
    esac
}

# Function to execute a local module
install_module() {
    local module_name="$1"
    local display_name="$2"
    local module_path="$MODULES_DIR/${module_name}.sh"
    
    # Check if module file exists
    if [[ ! -f "$module_path" ]]; then
        log_error "Module file not found: $module_path"
        FAILED_INSTALLS+=("$display_name")
        return 1
    fi
    
    log_info "Installing $display_name..."
    
    # Set environment variables that modules might need
    export WALLPAPER_REPO="${WALLPAPER_REPO:-SidSm/UbuntuSetup}"
    
    # Execute the local module
    if bash "$module_path"; then
        SUCCESSFUL_INSTALLS+=("$display_name")
        log_info "✅ $display_name installed successfully"
        return 0
    else
        FAILED_INSTALLS+=("$display_name")
        log_error "❌ Failed to install $display_name"
        return 1
    fi
}

# Function to discover available local modules
discover_modules() {
    log_info "Discovering local modules in $MODULES_DIR..."
    
    # Check if modules directory exists
    if [[ ! -d "$MODULES_DIR" ]]; then
        log_error "Modules directory not found: $MODULES_DIR"
        return 1
    fi
    
    # Find all .sh files in modules directory
    local modules=""
    for module_file in "$MODULES_DIR"/*.sh; do
        # Check if files exist (handle case where no .sh files found)
        if [[ -f "$module_file" ]]; then
            # Extract module name (remove path and .sh extension)
            local module_name=$(basename "$module_file" .sh)
            modules="$modules $module_name"
        fi
    done
    
    # Remove leading space and sort
    modules=$(echo "$modules" | tr ' ' '\n' | sort | tr '\n' ' ')
    
    if [[ -z "$modules" ]]; then
        log_error "No module files found in $MODULES_DIR"
        return 1
    fi
    
    echo "$modules"
    return 0
}

# Function to categorize modules and get display names
get_module_info() {
    local module="$1"
    local display_name=""
    local category=""
    local default="n"
    
    # Define module categories and display names
    case "$module" in
        # System & Essential
        "utils") display_name="Essential Utilities"; category="system"; default="y" ;;
        "git") display_name="Git"; category="system"; default="y" ;;
        "ssh-github") display_name="SSH & GitHub Setup"; category="system"; default="y" ;;
        
        # Development Tools
        "python") display_name="Python3 Environment"; category="development"; default="y" ;;
        "nodejs") display_name="Node.js & npm"; category="development"; default="y" ;;
        "vscode") display_name="Visual Studio Code"; category="development"; default="y" ;;
        "vscode-extensions") display_name="VS Code Extensions"; category="development"; default="y" ;;
        "docker") display_name="Docker"; category="development"; default="n" ;;
        "arduino") display_name="Arduino IDE"; category="development"; default="n" ;;
        
        # Browsers
        "brave") display_name="Brave Browser"; category="browsers"; default="y" ;;
        "firefox") display_name="Firefox"; category="browsers"; default="n" ;;
        
        # Multimedia & Creativity
        "vlc") display_name="VLC Media Player"; category="multimedia"; default="y" ;;
        "gimp") display_name="GIMP"; category="multimedia"; default="n" ;;
        "blender") display_name="Blender"; category="multimedia"; default="n" ;;
        "obs") display_name="OBS Studio"; category="multimedia"; default="n" ;;
        "prusaslicer") display_name="PrusaSlicer (3D Printing)"; category="multimedia"; default="n" ;;
        
        # Communication
        "telegram") display_name="Telegram Desktop"; category="communication"; default="n" ;;
        "discord") display_name="Discord"; category="communication"; default="n" ;;
        
        # System Utilities
        "tmux") display_name="tmux"; category="utilities"; default="y" ;;
        "htop") display_name="htop"; category="utilities"; default="y" ;;
        "vim") display_name="Vim & Neovim"; category="utilities"; default="y" ;;
        "gnome-tweaks") display_name="GNOME Tweaks"; category="utilities"; default="y" ;;
        
        # Hardware & Crypto
        "rpi-imager") display_name="Raspberry Pi Imager"; category="hardware"; default="n" ;;
        "trezor") display_name="Trezor Suite"; category="crypto"; default="n" ;;
        "electrum") display_name="Electrum Wallet"; category="crypto"; default="n" ;;
        
        # Office & Productivity
        "libreoffice") display_name="LibreOffice"; category="office"; default="n" ;;
        
        # Special
        "wallpaper") display_name="Custom Wallpaper Setup"; category="special"; default="n" ;;
        
        # Default for unknown modules
        *) display_name="$(echo $module | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"; category="other"; default="n" ;;
    esac
    
    echo "$display_name|$category|$default"
}

# Function to show final installation report
show_final_report() {
    echo ""
    echo "=================================================="
    log_header "📊 INSTALLATION REPORT"
    echo "=================================================="
    
    if [[ ${#SUCCESSFUL_INSTALLS[@]} -gt 0 ]]; then
        echo ""
        log_info "✅ SUCCESSFUL INSTALLATIONS (${#SUCCESSFUL_INSTALLS[@]}):"
        for app in "${SUCCESSFUL_INSTALLS[@]}"; do
            echo -e "  ${GREEN}✓${NC} $app"
        done
    fi
    
    if [[ ${#FAILED_INSTALLS[@]} -gt 0 ]]; then
        echo ""
        log_error "❌ FAILED INSTALLATIONS (${#FAILED_INSTALLS[@]}):"
        for app in "${FAILED_INSTALLS[@]}"; do
            echo -e "  ${RED}✗${NC} $app"
        done
        echo ""
        log_warn "💡 You can manually install failed applications later or re-run the script."
    fi
    
    echo ""
    if [[ ${#FAILED_INSTALLS[@]} -eq 0 ]]; then
        log_info "🎉 All selected applications installed successfully!"
    else
        log_warn "⚠️  Some installations failed. Check the logs above for details."
    fi
    echo "=================================================="
}

echo "🚀 Ubuntu Fresh Install Setup Script (Local Modules)"
echo "=================================================="
echo ""
echo "This script discovers and installs applications from local modules."
echo "Modules directory: $MODULES_DIR"
echo ""

# Discover available modules
available_modules=$(discover_modules)
if [[ $? -ne 0 ]] || [[ -z "$available_modules" ]]; then
    log_error "Failed to discover modules. Exiting."
    exit 1
fi

log_info "Found $(echo "$available_modules" | wc -w) modules"

# Ask about system update first
echo ""
log_header "=== SYSTEM UPDATES ==="
if ask_install "system-updates" "system updates (recommended)" "system" "y"; then
    INSTALL_UPDATES=true
else
    INSTALL_UPDATES=false
fi

# Group modules by category and ask for installation
declare -A categories
declare -A category_modules

# Categorize modules
for module in $available_modules; do
    if [[ "$module" == "wallpaper" ]]; then
        continue  # Handle wallpaper specially
    fi
    
    module_info=$(get_module_info "$module")
    display_name=$(echo "$module_info" | cut -d'|' -f1)
    category=$(echo "$module_info" | cut -d'|' -f2)
    default=$(echo "$module_info" | cut -d'|' -f3)
    
    categories["$category"]=1
    # Use a different delimiter to avoid issues with spaces
    category_modules["$category"]+="$module|||$display_name|||$default;;;"
done

# Ask for each category
for category in system development browsers multimedia communication utilities hardware crypto office other; do
    if [[ -n "${categories[$category]}" ]]; then
        echo ""
        case "$category" in
            "system") log_header "=== SYSTEM & ESSENTIAL ===" ;;
            "development") log_header "=== DEVELOPMENT TOOLS ===" ;;
            "browsers") log_header "=== BROWSERS ===" ;;
            "multimedia") log_header "=== MULTIMEDIA & CREATIVITY ===" ;;
            "communication") log_header "=== COMMUNICATION ===" ;;
            "utilities") log_header "=== SYSTEM UTILITIES ===" ;;
            "hardware") log_header "=== HARDWARE TOOLS ===" ;;
            "crypto") log_header "=== CRYPTOCURRENCY ===" ;;
            "office") log_header "=== OFFICE & PRODUCTIVITY ===" ;;
            "other") log_header "=== OTHER APPLICATIONS ===" ;;
        esac
        
        # Process modules in this category
        # Split by ;;; delimiter and process each entry
        IFS=';;;' read -ra module_entries <<< "${category_modules[$category]}"
        for module_entry in "${module_entries[@]}"; do
            if [[ -n "$module_entry" ]]; then
                # Extract module info using ||| delimiter
                module=$(echo "$module_entry" | cut -d'|' -f1)
                display_name=$(echo "$module_entry" | cut -d'|' -f4)
                default=$(echo "$module_entry" | cut -d'|' -f7)
                
                ask_install "$module" "$display_name" "$category" "$default"
            fi
        done
    fi
done

# Handle wallpaper setup specially
echo ""
log_header "=== WALLPAPER SETUP ==="
if ask_install "wallpaper" "Custom wallpaper from GitHub repo" "special" "n"; then
    echo -ne "${BLUE}Enter your GitHub username (default: SidSm): ${NC}"
    read -r GITHUB_USER
    echo -ne "${BLUE}Enter your wallpapers repository name (default: UbuntuSetup): ${NC}"
    read -r GITHUB_REPO
    
    GITHUB_USER="${GITHUB_USER:-SidSm}"
    GITHUB_REPO="${GITHUB_REPO:-UbuntuSetup}"
    export WALLPAPER_REPO="$GITHUB_USER/$GITHUB_REPO"
fi

echo ""
echo "🔄 Starting installation..."
echo ""

# Create downloads directory
mkdir -p ~/Downloads/setup_files
cd ~/Downloads/setup_files

# Update system first
if [[ "$INSTALL_UPDATES" == true ]]; then
    log_info "Updating system packages..."
    if sudo apt update && sudo apt upgrade -y; then
        SUCCESSFUL_INSTALLS+=("System updates")
    else
        FAILED_INSTALLS+=("System updates")
    fi
fi

# Install essential dependencies
log_info "Installing essential dependencies..."
if sudo apt update && sudo apt install -y curl wget gpg software-properties-common apt-transport-https ca-certificates gnupg lsb-release; then
    SUCCESSFUL_INSTALLS+=("Essential dependencies")
else
    FAILED_INSTALLS+=("Essential dependencies")
fi

# Install selected modules
for module in $available_modules; do
    if [[ "${MODULE_SELECTIONS[$module]}" == "true" ]]; then
        module_info=$(get_module_info "$module")
        display_name=$(echo "$module_info" | cut -d'|' -f1)
        install_module "$module" "$display_name"
    fi
done

# Cleanup
log_info "Cleaning up..."
cd ~
rm -rf ~/Downloads/setup_files
sudo apt autoremove -y
sudo apt autoclean

# Show final report
show_final_report

echo ""
echo "🔄 Please reboot your system to ensure all applications work correctly."
if [[ " ${SUCCESSFUL_INSTALLS[*]} " =~ " Docker " ]]; then
    echo "📝 Note: You may need to log out and back in for Docker group permissions to take effect."
fi
if [[ " ${SUCCESSFUL_INSTALLS[*]} " =~ " SSH & GitHub Setup " ]]; then
    echo "🔑 Note: Your SSH key has been generated and copied to clipboard. Add it to GitHub in Settings > SSH Keys."
fi
echo ""
echo "🎉 Setup completed!"