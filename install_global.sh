#!/bin/bash

# ReproLab Global Installation Script
# This script builds and installs the ReproLab JupyterLab extension globally

set -e

echo "🚀 Installing ReproLab JupyterLab Extension Globally..."

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

echo "🧶 Installing dependencies..."
jlpm install

echo "🔨 Building the extension..."
jlpm build:lib:prod
jupyter labextension build .

echo "🐍 Installing Python package globally..."
pip install .

echo "🔓 Enabling ReproLab extension..."
jupyter labextension enable reprolab

echo "✅ ReproLab global installation completed successfully!"
echo ""
echo "🔍 Verifying installation..."
if [ -d "/opt/homebrew/anaconda3/share/jupyter/labextensions/reprolab" ]; then
    echo "✅ ReproLab extension is installed and enabled"
else
    echo "❌ ReproLab extension installation verification failed"
    exit 1
fi

echo ""
echo "To start JupyterLab with ReproLab from any directory:"
echo "  jupyter lab"
echo ""
echo "The ReproLab panel will appear in the left sidebar." 
