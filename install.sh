#!/bin/bash

# Password Generator - Termux Installation Script
# Professional installation system with comprehensive error handling
# Version: 1.0.0
# License: MIT License

set -e

# Color definitions for professional output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Installation configuration constants
readonly INSTALL_DIR="$PREFIX/opt/password-generator"
readonly BIN_DIR="$PREFIX/bin"
readonly EXECUTABLE_NAME="passgen"
readonly SCRIPT_NAME="maincode.py"
readonly VERSION="1.0.0"

# Global status tracking
INSTALLATION_SUCCESS=false

print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║         PASSWORD GENERATOR - TERMUX INSTALLER                ║"
    echo "║                                                               ║"
    echo "║                   Professional Installation                   ║"
    echo "║                        Version $VERSION                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

log_step() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Error handling function
handle_error() {
    local line_number=$1
    local error_code=$2
    log_error "Installation failed at line $line_number with exit code $error_code"
    log_error "Please check the error messages above and try again"
    
    if [ "$INSTALLATION_SUCCESS" = "false" ]; then
        log_warning "Attempting to clean up partial installation..."
        cleanup_partial_installation
    fi
    
    exit $error_code
}

# Set error trap
trap 'handle_error $LINENO $?' ERR

cleanup_partial_installation() {
    log_step "Cleaning up partial installation..."
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR" 2>/dev/null || true
        log_debug "Removed installation directory"
    fi
    
    if [ -f "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        rm -f "$BIN_DIR/$EXECUTABLE_NAME" 2>/dev/null || true
        log_debug "Removed executable link"
    fi
}

verify_termux_environment() {
    log_step "Verifying Termux environment..."
    
    if [ -z "$PREFIX" ]; then
        log_error "This installer requires Termux environment"
        log_error "Please execute this script within Termux terminal"
        exit 1
    fi
    
    if [ ! -d "$PREFIX" ]; then
        log_error "Termux PREFIX directory not accessible: $PREFIX"
        exit 1
    fi
    
    log_success "Termux environment verified (PREFIX: $PREFIX)"
}

check_system_requirements() {
    log_step "Checking system requirements..."
    
    # Check available disk space (require at least 10MB)
    local available_space
    available_space=$(df "$PREFIX" | awk 'NR==2 {print $4}')
    
    if [ "$available_space" -lt 10240 ]; then
        log_warning "Low disk space detected. Installation may fail."
        echo -e "${YELLOW}Continue anyway? (y/N): ${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled due to insufficient disk space"
            exit 1
        fi
    fi
    
    # Check write permissions
    if [ ! -w "$PREFIX" ]; then
        log_error "No write permission to PREFIX directory: $PREFIX"
        exit 1
    fi
    
    log_success "System requirements satisfied"
}

install_system_dependencies() {
    log_step "Managing system dependencies..."
    
    # Update package repositories
    log_step "Updating package repositories..."
    if ! pkg update -y >/dev/null 2>&1; then
        log_warning "Package repository update failed, attempting to continue"
    else
        log_success "Package repositories updated"
    fi
    
    # Install Python if not available
    if ! command -v python >/dev/null 2>&1; then
        log_step "Installing Python runtime environment..."
        if ! pkg install python -y; then
            log_error "Failed to install Python runtime"
            log_error "Please install Python manually: pkg install python"
            exit 1
        fi
        log_success "Python runtime installed"
    else
        local python_version
        python_version=$(python --version 2>&1 | awk '{print $2}')
        log_success "Python runtime available (version: $python_version)"
    fi
    
    # Verify Python installation
    if ! python -c "import secrets, string, os, sys" 2>/dev/null; then
        log_error "Python installation verification failed"
        log_error "Required Python modules are not available"
        exit 1
    fi
    
    log_success "Python environment validation completed"
}

create_installation_directories() {
    log_step "Creating installation directory structure..."
    
    # Create main installation directory
    if ! mkdir -p "$INSTALL_DIR"; then
        log_error "Failed to create installation directory: $INSTALL_DIR"
        exit 1
    fi
    
    # Ensure bin directory exists
    if ! mkdir -p "$BIN_DIR"; then
        log_error "Failed to access bin directory: $BIN_DIR"
        exit 1
    fi
    
    # Set appropriate permissions
    chmod 755 "$INSTALL_DIR"
    
    log_success "Directory structure created successfully"
}

install_application_files() {
    log_step "Installing application files..."
    
    # Verify source file exists
    if [ ! -f "src/$SCRIPT_NAME" ]; then
        log_error "Source file not found: src/$SCRIPT_NAME"
        log_error "Please ensure you are running this script from the repository root"
        exit 1
    fi
    
    # Copy main application file
    if ! cp "src/$SCRIPT_NAME" "$INSTALL_DIR/"; then
        log_error "Failed to copy application file to installation directory"
        exit 1
    fi
    
    # Set executable permissions
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Verify file integrity
    if ! python -m py_compile "$INSTALL_DIR/$SCRIPT_NAME"; then
        log_error "Application file contains syntax errors"
        exit 1
    fi
    
    log_success "Application files installed and verified"
}

create_system_executable() {
    log_step "Creating system-wide executable..."
    
    # Create executable wrapper script
    cat > "$BIN_DIR/$EXECUTABLE_NAME" << EOF
#!/bin/bash
# Password Generator System Executable
# Provides system-wide access to password generator functionality
# Version: $VERSION

# Execute the main Python application
exec python "$INSTALL_DIR/$SCRIPT_NAME" "\$@"
EOF

    # Set executable permissions
    chmod +x "$BIN_DIR/$EXECUTABLE_NAME"
    
    # Verify executable functionality
    if ! "$BIN_DIR/$EXECUTABLE_NAME" --version >/dev/null 2>&1; then
        log_warning "Executable verification produced warnings, but installation continues"
    fi
    
    log_success "System executable created: $BIN_DIR/$EXECUTABLE_NAME"
}

install_documentation() {
    log_step "Installing documentation and configuration files..."
    
    # Copy documentation if available
    if [ -d "docs" ]; then
        cp -r docs "$INSTALL_DIR/" 2>/dev/null || log_warning "Documentation copy encountered issues"
        log_success "Documentation files installed"
    else
        log_warning "Documentation directory not found, creating basic documentation"
    fi
    
    # Create installation information file
    cat > "$INSTALL_DIR/INSTALL_INFO.txt" << EOF
Password Generator - Installation Information
============================================

Installation Date: $(date)
Installation Directory: $INSTALL_DIR
Executable Location: $BIN_DIR/$EXECUTABLE_NAME
Version: $VERSION
Platform: Termux $(uname -o 2>/dev/null || echo "Unknown")

Usage Instructions:
- Launch application: $EXECUTABLE_NAME
- Command line help: $EXECUTABLE_NAME --help
- Check version: $EXECUTABLE_NAME --version

Features:
- Cryptographically secure password generation
- Multiple password types (strong, PIN, alphabetic, memorable)
- Password strength analysis with detailed feedback
- Professional terminal interface with color coding
- Command line and interactive modes

Security Information:
- Uses Python secrets module for secure random generation
- No network connectivity required
- No password storage or logging
- Suitable for production security requirements

Uninstallation:
- Remove installation directory: rm -rf $INSTALL_DIR
- Remove executable: rm -f $BIN_DIR/$EXECUTABLE_NAME

Support:
- GitHub repository for issues and contributions
- Comprehensive documentation included with installation
EOF

    log_success "Documentation and configuration installed"
}

create_desktop_integration() {
    log_step "Setting up desktop integration..."
    
    # Create desktop entry directory
    local desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$desktop_dir" 2>/dev/null || true
    
    # Create desktop entry file
    if [ -w "$desktop_dir" ]; then
        cat > "$desktop_dir/password-generator.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Password Generator
Comment=Secure Password Generator for Termux
Exec=$BIN_DIR/$EXECUTABLE_NAME
Icon=dialog-password
Terminal=true
Categories=Utility;Security;System;
Keywords=password;security;generator;encryption;
StartupNotify=false
EOF
        log_success "Desktop integration configured"
    else
        log_warning "Desktop integration setup skipped (directory not writable)"
    fi
}

perform_installation_verification() {
    log_step "Performing comprehensive installation verification..."
    
    local verification_errors=0
    
    # Verify installation directory
    if [ ! -d "$INSTALL_DIR" ]; then
        log_error "Installation directory missing: $INSTALL_DIR"
        ((verification_errors++))
    fi
    
    # Verify main application file
    if [ ! -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        log_error "Main application file missing: $INSTALL_DIR/$SCRIPT_NAME"
        ((verification_errors++))
    fi
    
    # Verify executable
    if [ ! -f "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        log_error "System executable missing: $BIN_DIR/$EXECUTABLE_NAME"
        ((verification_errors++))
    fi
    
    # Verify permissions
    if [ ! -x "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        log_error "Main application file not executable"
        ((verification_errors++))
    fi
    
    if [ ! -x "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        log_error "System executable not properly configured"
        ((verification_errors++))
    fi
    
    # Verify Python syntax
    if ! python -m py_compile "$INSTALL_DIR/$SCRIPT_NAME"; then
        log_error "Application contains syntax errors"
        ((verification_errors++))
    fi
    
    # Test basic functionality
    if ! "$BIN_DIR/$EXECUTABLE_NAME" --version >/dev/null 2>&1; then
        log_warning "Basic functionality test produced warnings"
    fi
    
    if [ $verification_errors -eq 0 ]; then
        log_success "Installation verification completed successfully"
        INSTALLATION_SUCCESS=true
        return 0
    else
        log_error "Installation verification failed with $verification_errors error(s)"
        return 1
    fi
}

display_installation_summary() {
    echo
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗"
    echo -e "║                                                               ║"
    echo -e "║                   INSTALLATION COMPLETED                     ║"
    echo -e "║                                                               ║"
    echo -e "║   Password Generator has been successfully installed.         ║"
    echo -e "║                                                               ║"
    echo -e "║   Launch Command: ${YELLOW}$EXECUTABLE_NAME${GREEN}                                   ║"
    echo -e "║                                                               ║"
    echo -e "║   Available Features:                                         ║"
    echo -e "║   • Cryptographically secure password generation             ║"
    echo -e "║   • Multiple password types and formats                      ║"
    echo -e "║   • Comprehensive strength analysis                          ║"
    echo -e "║   • Professional terminal interface                          ║"
    echo -e "║   • Command line and interactive modes                       ║"
    echo -e "║                                                               ║"
    echo -e "║   Installation Location: $INSTALL_DIR    ║"
    echo -e "║                                                               ║"
    echo -e "╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo
    echo -e "${CYAN}${BOLD}Quick Reference Commands:${NC}"
    echo -e "  ${BLUE}$EXECUTABLE_NAME${NC}                    Launch interactive password generator"
    echo -e "  ${BLUE}$EXECUTABLE_NAME --help${NC}            Display command line options"
    echo -e "  ${BLUE}$EXECUTABLE_NAME --version${NC}         Show version information"
    echo -e "  ${BLUE}$EXECUTABLE_NAME -g strong -l 20${NC}   Generate 20-character strong password"
    
    echo
    echo -e "${PURPLE}${BOLD}Security Notice:${NC}"
    echo -e "All password generation uses cryptographically secure methods suitable"
    echo -e "for production environments. No passwords are stored or transmitted."
    
    echo
    echo -e "${GREEN}Installation completed successfully! Enjoy secure password generation! 🔐${NC}"
}

main() {
    # Display banner
    print_banner
    
    # Main installation process
    log_step "Initiating Password Generator installation process..."
    echo
    
    # Execute installation steps
    verify_termux_environment
    check_system_requirements
    install_system_dependencies
    create_installation_directories
    install_application_files
    create_system_executable
    install_documentation
    create_desktop_integration
    
    # Perform verification
    if perform_installation_verification; then
        display_installation_summary
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Script execution protection
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
