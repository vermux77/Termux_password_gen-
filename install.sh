#!/bin/bash

# Password Generator - Termux Installation Script (Fixed)
# Version: 1.0.1

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

# Installation configuration constants
readonly INSTALL_DIR="$PREFIX/opt/password-generator"
readonly BIN_DIR="$PREFIX/bin"
readonly EXECUTABLE_NAME="passgen"
readonly SCRIPT_NAME="maincode.py"   # FIXED
readonly VERSION="1.0.1"

INSTALLATION_SUCCESS=false

# (geri kalan her şey aynı...)

install_application_files() {
    log_step "Installing application files..."
    
    # Verify source file exists
    if [ ! -f "$SCRIPT_NAME" ]; then
        log_error "Source file not found: $SCRIPT_NAME"
        log_error "Please ensure you are running this script from the repository root"
        exit 1
    fi
    
    # Copy main application file
    if ! cp "$SCRIPT_NAME" "$INSTALL_DIR/"; then
        log_error "Failed to copy application file to installation directory"
        exit 1
    fi
    
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    if ! python -m py_compile "$INSTALL_DIR/$SCRIPT_NAME"; then
        log_error "Application file contains syntax errors"
        exit 1
    fi
    
    log_success "Application files installed and verified"
}

create_system_executable() {
    log_step "Creating system-wide executable..."
    
    cat > "$BIN_DIR/$EXECUTABLE_NAME" << EOF
#!/bin/bash
exec python "$INSTALL_DIR/$SCRIPT_NAME" "\$@"
EOF

    chmod +x "$BIN_DIR/$EXECUTABLE_NAME"
    
    if ! "$BIN_DIR/$EXECUTABLE_NAME" --version >/dev/null 2>&1; then
        log_warning "Executable verification produced warnings, but installation continues"
    fi
    
    log_success "System executable created: $BIN_DIR/$EXECUTABLE_NAME"
}
