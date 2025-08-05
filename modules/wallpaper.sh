#!/bin/bash
# wallpapers/wallpaper.sh - Wallpaper Setup from GitHub Repository

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[WALLPAPER]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WALLPAPER]${NC} $1"
}

log_error() {
    echo -e "${RED}[WALLPAPER]${NC} $1"
}

# Check if WALLPAPER_REPO environment variable is set, if not use default
if [[ -z "$WALLPAPER_REPO" ]]; then
    log_warn "WALLPAPER_REPO not set, using default: SidSm/UbuntuSetup"
    WALLPAPER_REPO="SidSm/UbuntuSetup"
fi

# Create wallpapers directory
mkdir -p ~/Pictures/Wallpapers

# Function to list available wallpapers
list_wallpapers() {
    log_info "Fetching available wallpapers from $WALLPAPER_REPO..."
    
    # Get repository contents from the wallpapers directory
    local api_url="https://api.github.com/repos/$WALLPAPER_REPO/contents/wallpapers"
    local response=$(curl -s "$api_url")
    
    # Check if repo exists and is accessible
    if echo "$response" | grep -q '"message": "Not Found"'; then
        log_error "Repository $WALLPAPER_REPO not found or not accessible."
        return 1
    fi
    
    # Extract image files (jpg, jpeg, png, webp, bmp)
    local images=$(echo "$response" | grep -E '"name".*\.(jpg|jpeg|png|webp|bmp)"' | sed 's/.*"name": *"\([^"]*\)".*/\1/' | sort)
    
    if [[ -z "$images" ]]; then
        log_error "No image files found in the wallpapers directory."
        return 1
    fi
    
    echo "Available wallpapers:"
    echo "$images" | nl -w2 -s'. '
    echo ""
    
    # Store images in a global variable for later use
    AVAILABLE_IMAGES="$images"
    return 0
}

# Function to download and set wallpaper
set_wallpaper() {
    local filename="$1"
    local download_url="https://raw.githubusercontent.com/$WALLPAPER_REPO/master/wallpapers/$filename"
    local local_path="$HOME/Pictures/Wallpapers/$filename"
    
    log_info "Downloading $filename..."
    log_info "From: $download_url"
    
    if wget -q "$download_url" -O "$local_path" 2>/dev/null; then
        log_info "Downloaded successfully to $local_path"
        
        # Set as wallpaper based on desktop environment
        if command -v gsettings >/dev/null 2>&1; then
            # GNOME/Ubuntu Desktop
            gsettings set org.gnome.desktop.background picture-uri "file://$local_path"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$local_path"
            gsettings set org.gnome.desktop.background picture-options 'zoom'
            log_info "✅ Wallpaper set successfully for GNOME!"
        elif command -v xfconf-query >/dev/null 2>&1; then
            # XFCE
            xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$local_path"
            log_info "✅ Wallpaper set successfully for XFCE!"
        elif command -v pcmanfm >/dev/null 2>&1; then
            # LXDE
            pcmanfm --set-wallpaper="$local_path"
            log_info "✅ Wallpaper set successfully for LXDE!"
        elif command -v feh >/dev/null 2>&1; then
            # Generic X11 with feh
            feh --bg-scale "$local_path"
            log_info "✅ Wallpaper set successfully with feh!"
        else
            log_warn "Could not automatically set wallpaper. Desktop environment not recognized."
            log_info "Wallpaper saved to: $local_path"
            log_info "You can set it manually through your desktop settings."
        fi
        return 0
    else
        log_error "Failed to download $filename from $download_url"
        log_error "Please check if the file exists in your repository."
        return 1
    fi
}

# Main wallpaper setup logic
if list_wallpapers; then
    echo -ne "${BLUE}Enter your choice (number or filename): ${NC}"
    read -r wallpaper_choice
    
    # Check if user entered a number
    if [[ "$wallpaper_choice" =~ ^[0-9]+$ ]]; then
        log_info "You selected option #$wallpaper_choice"
        
        # Get the filename by line number from stored images
        selected_wallpaper=$(echo "$AVAILABLE_IMAGES" | sed -n "${wallpaper_choice}p")
        
        if [[ -z "$selected_wallpaper" ]]; then
            log_error "Invalid number selection. Please choose a number from 1 to $(echo "$AVAILABLE_IMAGES" | wc -l)."
            exit 1
        fi
        
        log_info "Selected wallpaper: $selected_wallpaper"
        wallpaper_choice="$selected_wallpaper"
    else
        log_info "You entered filename: $wallpaper_choice"
    fi
    
    if [[ -n "$wallpaper_choice" ]] && set_wallpaper "$wallpaper_choice"; then
        log_info "✅ Wallpaper setup completed successfully"
    else
        log_error "Invalid selection or failed to set wallpaper"
        exit 1
    fi
else
    log_error "Could not fetch wallpapers from repository"
    exit 1
fi