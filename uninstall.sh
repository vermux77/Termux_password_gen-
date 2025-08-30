#!/bin/bash

# Password Generator - Termux Uninstallation Script
# Complete removal of all application components
# Version: 1.0.0
# License: MIT License

set -e

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Installation paths
readonly INSTALL_DIR="$PREFIX/opt/password-generator"
readonly BIN_DIR="$PREFIX/bin"
readonly EXECUTABLE_NAME="passgen"
readonly DESKTOP_FILE="$HOME/.local/share/applications/password-generator.desktop"

print_banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║         PASSWORD GENERATOR - UNINSTALLER                     ║"
    echo "║                                                               ║"
    echo "║                    Complete Removal                          ║"
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

confirm_uninstallation() {
    echo -e "${YELLOW}${BOLD}ATTENTION:${NC} This will completely remove Password Generator from your system."
    echo
    echo "The following components will be removed:"
    echo "• Application files and directories"
    echo "• System executable command"
    echo "• Documentation and configuration files"
    echo "• Desktop integration entries"
    echo
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    echo
    echo -e "${CYAN}Do you want to proceed with uninstallation? (y/N): ${NC}"
    
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        echo
        echo -e "${GREEN}Uninstallation cancelled. Password Generator remains installed.${NC}"
        exit 0
    fi
    
    echo
    log_step "Proceeding with uninstallation..."
}

check_installation_status() {
    log_step "Checking current installation status..."
    
    local components_found=0
    
    if [ -d "$INSTALL_DIR" ]; then
        log_step "Found installation directory: $INSTALL_DIR"
        ((components_found++))
    fi
    
    if [ -f "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        log_step "Found system executable: $BIN_DIR/$EXECUTABLE_NAME"
        ((components_found++))
    fi
    
    if [ -f "$DESKTOP_FILE" ]; then
        log_step "Found desktop entry: $DESKTOP_FILE"
        ((components_found++))
    fi
    
    if [ $components_found -eq 0 ]; then
        log_warning "No installation components found"
        echo
        echo -e "${YELLOW}Password Generator does not appear to be installed.${NC}"
        echo "If you believe this is incorrect, you may need to manually remove any remaining files."
        exit 0
    fi
    
    log_success "Found $components_found installation component(s)"
}

backup_configuration() {
    log_step "Creating backup of user configuration..."
    
    local backup_dir="$HOME/.password-generator-backup-$(date +%Y%m%d_%H%M%S)"
    
    # Check if there are any user configurations to backup
    if [ -f "$INSTALL_DIR/user_config.ini" ] || [ -f "$INSTALL_DIR/user_preferences.json" ]; then
        mkdir -p "$backup_dir"
        
        # Backup configuration files if they exist
        if [ -f "$INSTALL_DIR/user_config.ini" ]; then
            cp "$INSTALL_DIR/user_config.ini" "$backup_dir/" 2>/dev/null || true
        fi
        
        if [ -f "$INSTALL_DIR/user_preferences.json" ]; then
            cp "$INSTALL_DIR/user_preferences.json" "$backup_dir/" 2>/dev/null || true
        fi
        
        log_success "Configuration backup created: $backup_dir"
    else
        log_step "No user configuration found to backup"
    fi
}

remove_application_files() {
    log_step "Removing application files and directories..."
    
    local removal_errors=0
    
    # Remove main installation directory
    if [ -d "$INSTALL_DIR" ]; then
        if rm -rf "$INSTALL_DIR" 2>/dev/null; then
            log_success "Application directory removed: $INSTALL_DIR"
        else
            log_error "Failed to remove application directory: $INSTALL_DIR"
            ((removal_errors++))
        fi
    fi
    
    # Remove system executable
    if [ -f "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        if rm -f "$BIN_DIR/$EXECUTABLE_NAME" 2>/dev/null; then
            log_success "System executable removed: $BIN_DIR/$EXECUTABLE_NAME"
        else
            log_error "Failed to remove system executable: $BIN_DIR/$EXECUTABLE_NAME"
            ((removal_errors++))
        fi
    fi
    
    # Remove desktop entry
    if [ -f "$DESKTOP_FILE" ]; then
        if rm -f "$DESKTOP_FILE" 2>/dev/null; then
            log_success "Desktop entry removed: $DESKTOP_FILE"
        else
            log_error "Failed to remove desktop entry: $DESKTOP_FILE"
            ((removal_errors++))
        fi
    fi
    
    # Clean up any remaining symbolic links
    find "$PREFIX/bin" -name "*passgen*" -type l -delete 2>/dev/null || true
    
    if [ $removal_errors -gt 0 ]; then
        log_warning "Some files could not be removed automatically"
        echo "You may need to remove them manually with appropriate permissions"
    fi
}

verify_removal() {
    log_step "Verifying complete removal..."
    
    local verification_issues=0
    
    # Check if installation directory still exists
    if [ -d "$INSTALL_DIR" ]; then
        log_warning "Installation directory still exists: $INSTALL_DIR"
        ((verification_issues++))
    fi
    
    # Check if executable still exists
    if [ -f "$BIN_DIR/$EXECUTABLE_NAME" ]; then
        log_warning "System executable still exists: $BIN_DIR/$EXECUTABLE_NAME"
        ((verification_issues++))
    fi
    
    # Check if desktop entry still exists
    if [ -f "$DESKTOP_FILE" ]; then
        log_warning "Desktop entry still exists: $DESKTOP_FILE"
        ((verification_issues++))
    fi
    
    # Test if command is still available
    if command -v "$EXECUTABLE_NAME" >/dev/null 2>&1; then
        log_warning "Command '$EXECUTABLE_NAME' is still available in PATH"
        ((verification_issues++))
    fi
    
    if [ $verification_issues -eq 0 ]; then
        log_success "Uninstallation verification completed successfully"
        return 0
    else
        log_warning "Verification detected $verification_issues potential issue(s)"
        return 1
    fi
}

clean_package_cache() {
    log_step "Cleaning package cache (optional)..."
    
    # Clean apt cache if the user wants to
    echo -e "${CYAN}Clean package cache to free up space? (y/N): ${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        if pkg clean >/dev/null 2>&1; then
            log_success "Package cache cleaned"
        else
            log_warning "Package cache cleaning encountered issues"
        fi
    else
        log_step "Package cache cleaning skipped"
    fi
}

display_completion_summary() {
    echo
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗"
    echo -e "║                                                               ║"
    echo -e "║                 UNINSTALLATION COMPLETED                     ║"
    echo -e "║                                                               ║"
    echo -e "║   Password Generator has been completely removed.             ║"
    echo -e "║                                                               ║"
    echo -e "║   Removed Components:                                         ║"
    echo -e "║   • Application files and directories                        ║"
    echo -e "║   • System executable command                                 ║"
    echo -e "║   • Documentation and configuration                          ║"
    echo -e "║   • Desktop integration entries                              ║"
    echo -e "║                                                               ║"
    echo -e "╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo
    echo -e "${CYAN}${BOLD}Post-Uninstallation Information:${NC}"
    echo -e "• All application files have been removed from your system"
    echo -e "• The '$EXECUTABLE_NAME' command is no longer available"
    echo -e "• No personal data was stored by the application"
    echo -e "• Configuration backups are preserved if they existed"
    
    echo
    echo -e "${PURPLE}${BOLD}Reinstallation:${NC}"
    echo -e "To reinstall Password Generator in the future:"
    echo -e "• Clone the repository: git clone <repository-url>"
    echo -e "• Run the installer: ./install.sh"
    
    echo
    echo -e "${GREEN}Thank you for using Password Generator! Stay secure! 🔐${NC}"
}

main() {
    # Display banner
    print_banner
    
    # Main uninstallation process
    log_step "Initiating Password Generator uninstallation process..."
    echo
    
    # Confirmation
    confirm_uninstallation
    
    # Execute uninstallation steps
    check_installation_status
    backup_configuration
    remove_application_files
    
    # Verification and cleanup
    if verify_removal; then
        clean_package_cache
        display_completion_summary
    else
        echo
        log_warning "Uninstallation completed with some issues"
        echo -e "${YELLOW}Some components may require manual removal${NC}"
        echo "Please check the warnings above for details"
    fi
}

# Execution protection and error handling
set -e
trap 'echo -e "\n${RED}Uninstallation interrupted${NC}"; exit 130' INT TERM

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi