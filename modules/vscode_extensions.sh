#!/bin/bash
# modules/vscode-extensions.sh - Essential VS Code Extensions Installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[VSCODE-EXT]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[VSCODE-EXT]${NC} $1"
}

log_error() {
    echo -e "${RED}[VSCODE-EXT]${NC} $1"
}

# Check if VS Code is installed
if ! command -v code >/dev/null 2>&1; then
    log_error "VS Code is not installed. Please install VS Code first."
    exit 1
fi

# Function to install extension with error handling
install_extension() {
    local extension_id="$1"
    local extension_name="$2"
    
    echo -ne "${BLUE}Installing $extension_name... ${NC}"
    if code --install-extension "$extension_id" >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌${NC}"
        return 1
    fi
}

# Arrays to track installation results
declare -a SUCCESSFUL_EXTENSIONS=()
declare -a FAILED_EXTENSIONS=()

log_info "Installing essential VS Code extensions..."
echo ""

# Python Development
echo -e "${BLUE}=== PYTHON DEVELOPMENT ===${NC}"
install_extension "ms-python.python" "Python" && SUCCESSFUL_EXTENSIONS+=("Python") || FAILED_EXTENSIONS+=("Python")
install_extension "ms-python.black-formatter" "Black Formatter" && SUCCESSFUL_EXTENSIONS+=("Black Formatter") || FAILED_EXTENSIONS+=("Black Formatter")
install_extension "ms-python.flake8" "Flake8" && SUCCESSFUL_EXTENSIONS+=("Flake8") || FAILED_EXTENSIONS+=("Flake8")
install_extension "ms-python.pylint" "Pylint" && SUCCESSFUL_EXTENSIONS+=("Pylint") || FAILED_EXTENSIONS+=("Pylint")

echo ""
# C/C++ Development
echo -e "${BLUE}=== C/C++ DEVELOPMENT ===${NC}"
install_extension "ms-vscode.cpptools" "C/C++" && SUCCESSFUL_EXTENSIONS+=("C/C++") || FAILED_EXTENSIONS+=("C/C++")
install_extension "ms-vscode.cpptools-extension-pack" "C/C++ Extension Pack" && SUCCESSFUL_EXTENSIONS+=("C/C++ Extension Pack") || FAILED_EXTENSIONS+=("C/C++ Extension Pack")
install_extension "ms-vscode.cmake-tools" "CMake Tools" && SUCCESSFUL_EXTENSIONS+=("CMake Tools") || FAILED_EXTENSIONS+=("CMake Tools")

echo ""
# PlatformIO (Arduino/Embedded Development)  
echo -e "${BLUE}=== EMBEDDED DEVELOPMENT ===${NC}"
install_extension "platformio.platformio-ide" "PlatformIO IDE" && SUCCESSFUL_EXTENSIONS+=("PlatformIO IDE") || FAILED_EXTENSIONS+=("PlatformIO IDE")

echo ""
# Docker Development
echo -e "${BLUE}=== DOCKER & CONTAINERS ===${NC}"
install_extension "ms-azuretools.vscode-docker" "Docker" && SUCCESSFUL_EXTENSIONS+=("Docker") || FAILED_EXTENSIONS+=("Docker")
install_extension "ms-vscode-remote.remote-containers" "Dev Containers" && SUCCESSFUL_EXTENSIONS+=("Dev Containers") || FAILED_EXTENSIONS+=("Dev Containers")

echo ""
# Windsurf (AI Assistant)
echo -e "${BLUE}=== AI ASSISTANT ===${NC}"
install_extension "Codeium.codeium" "Codeium AI (Windsurf alternative)" && SUCCESSFUL_EXTENSIONS+=("Codeium AI") || FAILED_EXTENSIONS+=("Codeium AI")

# Note: Windsurf is actually a separate editor, but we'll install Codeium as a similar AI assistant
if [[ " ${FAILED_EXTENSIONS[*]} " =~ " Codeium AI " ]]; then
    log_warn "Note: Windsurf is actually a separate AI-powered editor, not a VS Code extension."
    log_info "You can download Windsurf from: https://codeium.com/windsurf"
    log_info "Installing GitHub Copilot as alternative AI assistant..."
    install_extension "GitHub.copilot" "GitHub Copilot" && SUCCESSFUL_EXTENSIONS+=("GitHub Copilot") || FAILED_EXTENSIONS+=("GitHub Copilot")
fi

echo ""
echo "=================================================="
log_info "📊 EXTENSION INSTALLATION REPORT"
echo "=================================================="

if [[ ${#SUCCESSFUL_EXTENSIONS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ SUCCESSFULLY INSTALLED (${#SUCCESSFUL_EXTENSIONS[@]}):${NC}"
    for ext in "${SUCCESSFUL_EXTENSIONS[@]}"; do
        echo -e "  ${GREEN}✓${NC} $ext"
    done
fi

if [[ ${#FAILED_EXTENSIONS[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}❌ FAILED TO INSTALL (${#FAILED_EXTENSIONS[@]}):${NC}"
    for ext in "${FAILED_EXTENSIONS[@]}"; do
        echo -e "  ${RED}✗${NC} $ext"
    done
    echo ""
    log_warn "💡 You can manually install failed extensions from the VS Code Extensions marketplace."
fi

echo ""
if [[ ${#FAILED_EXTENSIONS[@]} -eq 0 ]]; then
    log_info "🎉 All extensions installed successfully!"
else
    log_warn "⚠️  Some extensions failed to install. VS Code should still work fine."
fi

echo ""
log_info "🚀 VS Code is now configured for:"
echo "  • Python development (with linting and formatting)"
echo "  • C/C++ development (with CMake support)"  
echo "  • Embedded development (PlatformIO for Arduino/ESP32/etc.)"
echo "  • Docker containerization"
echo "  • AI-assisted coding"
echo ""
log_info "💡 Consider downloading Windsurf for advanced AI features: https://codeium.com/windsurf"
echo "=================================================="