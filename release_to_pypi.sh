#!/bin/bash

# ReproLab PyPI Release Script
# This script builds and releases ReproLab to PyPI

set -e

# Store the original directory
ORIGINAL_DIR="$(pwd)"

echo "🚀 Preparing ReproLab for PyPI release..."

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: Please run this script from the ReproLab root directory"
    exit 1
fi

# Check if required tools are available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed."
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed."
    exit 1
fi

# Check if build tools are installed
if ! python3 -c "import build" &> /dev/null; then
    echo "📦 Installing build tools..."
    pip install build twine
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info/

# Build the frontend extension
echo "🔨 Building frontend extension..."
yarn install
yarn build:lib:prod
jupyter labextension build .

# Create clean build directory
echo "📁 Creating clean build directory..."
BUILD_DIR="/tmp/reprolab_build_$(date +%s)"
mkdir -p "$BUILD_DIR"

# Copy necessary files to clean directory
echo "📋 Copying files to clean build directory..."
cp -r reprolab src style package.json pyproject.toml README.md LICENSE MANIFEST.in "$BUILD_DIR/"

# Build Python package in clean directory
echo "🐍 Building Python package..."
cd "$BUILD_DIR"
echo "📁 Build directory: $(pwd)"
echo "📋 Files in build directory:"
ls -la
python3 -m build
echo "📋 Files after build:"
ls -la
if [ -d "dist" ]; then
    echo "📦 Contents of dist directory:"
    ls -la dist/
else
    echo "❌ No dist directory found"
fi

# Copy built packages back
echo "📦 Copying built packages..."
if [ -d "dist" ]; then
    cp -r dist "$ORIGINAL_DIR/"
    echo "✅ Packages copied successfully"
else
    echo "❌ Error: dist directory not found in build directory"
    exit 1
fi

# Return to original directory
cd "$ORIGINAL_DIR"

# Check the built package
echo "🔍 Checking built package..."
if [ -d "dist" ] && [ "$(ls -A dist/)" ]; then
    echo "📦 Found packages in dist/:"
    ls -la dist/
    echo ""
    python3 -m twine check dist/*
    echo "✅ Package built successfully!"
    echo ""
    echo "To upload to PyPI:"
    echo "  python3 -m twine upload dist/*"
    echo ""
    echo "To upload to Test PyPI (for testing):"
    echo "  python3 -m twine upload --repository testpypi dist/*"
    echo ""
    echo "To install from PyPI (after upload):"
    echo "  pip install reprolab"
else
    echo "❌ Error: No built packages found in dist/ directory"
    echo "Current directory: $(pwd)"
    echo "Contents of current directory:"
    ls -la
    if [ -d "dist" ]; then
        echo "dist directory exists but is empty"
    else
        echo "dist directory does not exist"
    fi
    exit 1
fi 
