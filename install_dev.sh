#!/bin/bash

# ReproLab Development Installation Script
# This script builds and installs the ReproLab JupyterLab extension in development mode
# For production use, use install_global.sh instead

set -e

echo "🚀 Installing ReproLab JupyterLab Extension (Development Mode)..."

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: Please run this script from the ReproLab root directory"
    exit 1
fi

# Check if Node.js and npm are available
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed. Please install npm first."
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Check if JupyterLab is installed
if ! python3 -c "import jupyterlab" &> /dev/null; then
    echo "❌ Error: JupyterLab is not installed. Please install JupyterLab first."
    echo "You can install it with: pip install jupyterlab"
    exit 1
fi

echo "🧶 Installing yarn dependencies..."
yarn install

echo "🔨 Building the extension..."
yarn build:lib:prod
jupyter labextension build .

echo "🐍 Installing Python package in development mode..."
pip install -e .

echo "🔓 Enabling ReproLab extension..."
jupyter labextension enable reprolab

echo "✅ ReproLab development installation completed successfully!"
echo ""
echo "⚠️  NOTE: This is a development installation. The extension will only work"
echo "   when running Jupyter Lab from this directory."
echo ""
echo "To start JupyterLab with ReproLab:"
echo "  jupyter lab"
echo ""
echo "For global installation (works from any directory), run:"
echo "  ./install_global.sh"
echo ""
echo "The ReproLab panel will appear in the left sidebar." 
