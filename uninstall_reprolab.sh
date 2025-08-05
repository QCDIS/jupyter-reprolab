#!/bin/bash

# Reprolab Uninstall Script
# This script uninstalls the reprolab Jupyter Lab extension and Python library
# without removing any files from the current directory

set -e  # Exit on any error

echo "🧹 Reprolab Uninstall Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_status "Starting Reprolab uninstallation..."

# 1. Uninstall Python package if installed
print_status "Checking for installed reprolab package..."
if command_exists pip; then
    if pip show reprolab >/dev/null 2>&1; then
        print_status "Uninstalling reprolab Python package..."
        pip uninstall -y reprolab
        print_success "Python package uninstalled"
    else
        print_warning "Reprolab Python package not found in pip"
    fi
else
    print_warning "pip not found, skipping Python package uninstall"
fi

# 2. Uninstall Jupyter Lab extension if installed
print_status "Checking for Jupyter Lab extension..."
if command_exists jupyter; then
    # Check if the extension is installed
    if jupyter labextension list 2>/dev/null | grep -q "reprolab"; then
        print_status "Uninstalling Jupyter Lab extension..."
        jupyter labextension uninstall reprolab
        print_success "Jupyter Lab extension uninstalled"
    else
        print_warning "Reprolab Jupyter Lab extension not found"
    fi
    
    # Also try to disable the extension
    print_status "Disabling Jupyter Lab extension..."
    jupyter labextension disable reprolab 2>/dev/null || print_warning "Could not disable extension"
else
    print_warning "jupyter not found, skipping Jupyter Lab extension uninstall"
fi

# 3. Alternative: Try to uninstall via npm if jupyter labextension doesn't work
print_status "Checking for npm-based Jupyter Lab extension..."
if command_exists npm; then
    if npm list -g @jupyter-widgets/jupyterlab-manager 2>/dev/null | grep -q "reprolab"; then
        print_status "Uninstalling Jupyter Lab extension via npm..."
        npm uninstall -g reprolab
        print_success "Jupyter Lab extension uninstalled via npm"
    else
        print_warning "Reprolab Jupyter Lab extension not found in npm"
    fi
else
    print_warning "npm not found, skipping npm-based uninstall"
fi

# 4. Clean up Jupyter config
print_status "Cleaning up Jupyter configuration..."
JUPYTER_CONFIG_DIR=$(jupyter --config-dir 2>/dev/null || echo "")
if [ -n "$JUPYTER_CONFIG_DIR" ] && [ -d "$JUPYTER_CONFIG_DIR" ]; then
    # Remove any reprolab-related config files
    find "$JUPYTER_CONFIG_DIR" -name "*reprolab*" -type f -delete 2>/dev/null || true
    print_success "Jupyter config cleaned up"
else
    print_warning "Jupyter config directory not found"
fi

# 5. Clean up Jupyter data
print_status "Cleaning up Jupyter data..."
JUPYTER_DATA_DIR=$(jupyter --data-dir 2>/dev/null || echo "")
if [ -n "$JUPYTER_DATA_DIR" ] && [ -d "$JUPYTER_DATA_DIR" ]; then
    # Remove any reprolab-related data files
    find "$JUPYTER_DATA_DIR" -name "*reprolab*" -type f -delete 2>/dev/null || true
    find "$JUPYTER_DATA_DIR" -name "*reprolab*" -type d -exec rm -rf {} + 2>/dev/null || true
    print_success "Jupyter data cleaned up"
else
    print_warning "Jupyter data directory not found"
fi

# 6. Check for conda environment
print_status "Checking for conda installation..."
if command_exists conda; then
    if conda list reprolab 2>/dev/null | grep -q "reprolab"; then
        print_status "Found reprolab in conda environment, uninstalling..."
        conda remove -y reprolab
        print_success "Reprolab removed from conda environment"
    else
        print_warning "Reprolab not found in conda environment"
    fi
else
    print_warning "conda not found, skipping conda uninstall"
fi

# 7. Check for pip in user directory
print_status "Checking for user-installed packages..."
if command_exists pip; then
    if pip list --user | grep -q "reprolab"; then
        print_status "Uninstalling user-installed reprolab package..."
        pip uninstall -y --user reprolab
        print_success "User-installed reprolab package uninstalled"
    else
        print_warning "User-installed reprolab package not found"
    fi
else
    print_warning "pip not found, skipping user package uninstall"
fi

echo
echo "🎉 Reprolab uninstallation completed!"
echo "========================================"
print_success "Python package has been uninstalled (if it was installed)"
print_success "Jupyter Lab extension has been uninstalled (if it was installed)"
print_success "Jupyter configuration and data have been cleaned up"

echo
print_status "What was attempted:"
echo "  ✓ Python package uninstall (pip)"
echo "  ✓ Jupyter Lab extension uninstall (jupyter labextension)"
echo "  ✓ Jupyter Lab extension uninstall (npm)"
echo "  ✓ Jupyter configuration cleanup"
echo "  ✓ Jupyter data cleanup"
echo "  ✓ Conda package uninstall"
echo "  ✓ User-installed package uninstall"

echo
print_warning "Note: If you installed reprolab in a virtual environment,"
print_warning "you may need to activate that environment and run this script again."

echo
print_warning "Note: If you installed reprolab globally with sudo,"
print_warning "you may need to run this script with sudo privileges."

echo
print_status "Uninstallation complete! 🧹" 
