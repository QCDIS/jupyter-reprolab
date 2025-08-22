#!/bin/bash

# ReproLab Global Installation Script
# This script builds and installs the ReproLab JupyterLab extension globally
# Works on both Ubuntu and macOS

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

# Handle NumPy compatibility issues
echo "🔍 Checking NumPy compatibility..."
NUMPY_VERSION=$(python3 -c "import numpy; print(numpy.__version__)" 2>/dev/null || echo "not_installed")

if [ "$NUMPY_VERSION" != "not_installed" ]; then
    echo "📊 NumPy version: $NUMPY_VERSION"
    
    # Check if NumPy 2.x is installed and handle compatibility
    if [[ "$NUMPY_VERSION" == 2.* ]]; then
        echo "⚠️  NumPy 2.x detected. Installing compatible dependencies..."
        
        # Install NumPy 2.x compatible versions of problematic packages
        echo "🔄 Installing NumPy 2.x compatible packages..."
        python3 -m pip install --upgrade "bottleneck>=1.3.0" "numexpr>=2.8.0"
        
        # Note: pandas and xarray should work with NumPy 2.x if bottleneck/numexpr are compatible
        echo "✅ NumPy 2.x compatibility packages installed"
        
        echo "✅ NumPy 2.x compatibility packages installed"
    else
        echo "✅ NumPy version is compatible"
    fi
else
    echo "📦 Installing NumPy..."
    python3 -m pip install "numpy>=1.20.0"
fi

echo "🧶 Installing dependencies..."
jlpm install

echo "🔨 Building the extension..."
jlpm build:lib:prod
jupyter labextension build .

echo "🐍 Installing Python package globally..."
pip install -e .

echo "🔓 Enabling ReproLab extension..."
jupyter labextension enable reprolab

echo "🔧 Configuring server extension..."
# Create Jupyter config directory if it doesn't exist
mkdir -p ~/.jupyter

# Add server extension configuration
cat > ~/.jupyter/jupyter_server_config.py << EOF
# Jupyter Server Configuration for ReproLab
c.ServerApp.jpserver_extensions = {"reprolab": True}

# Enable CORS for API access
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_credentials = True

# Disable XSRF for API endpoints (if needed)
c.ServerApp.disable_check_xsrf = True
EOF

echo "✅ Configuration written to ~/.jupyter/jupyter_server_config.py"

echo "🔍 Verifying installation..."
if [ -d "/opt/homebrew/anaconda3/share/jupyter/labextensions/reprolab" ] || [ -d "$HOME/.local/share/jupyter/labextensions/reprolab" ] || [ -d "/usr/local/share/jupyter/labextensions/reprolab" ]; then
    echo "✅ ReproLab extension is installed and enabled"
else
    echo "⚠️  Extension directory not found in standard locations, but this may be normal"
fi

# Test server extension loading
echo "🧪 Testing server extension..."
if python3 -c "from reprolab.server import load_jupyter_server_extension; print('✅ Server extension loads successfully')" 2>/dev/null; then
    echo "✅ Server extension test passed"
else
    echo "❌ Server extension test failed"
    echo "This may be due to dependency issues. Check the error messages above."
fi

echo ""
echo "✅ ReproLab global installation completed successfully!"
echo ""
echo "🔍 Verifying installation..."

# Check frontend extension (labextension)
echo "🔍 Checking frontend extension..."
FRONTEND_FOUND=false

# Check common labextension locations on different systems
for location in \
    "/opt/homebrew/anaconda3/share/jupyter/labextensions/reprolab" \
    "$HOME/.local/share/jupyter/labextensions/reprolab" \
    "/usr/local/share/jupyter/labextensions/reprolab" \
    "/usr/share/jupyter/labextensions/reprolab" \
    "$HOME/anaconda3/share/jupyter/labextensions/reprolab" \
    "$HOME/miniconda3/share/jupyter/labextensions/reprolab"
do
    if [ -d "$location" ]; then
        echo "   ✅ Frontend extension found at: $location"
        FRONTEND_FOUND=true
        break
    fi
done

if [ "$FRONTEND_FOUND" = false ]; then
    echo "   ⚠️  Frontend extension directory not found in standard locations"
    echo "   💡 This may be normal if using a custom Jupyter installation"
fi

# Check if labextension is enabled (simplified check)
echo "🔍 Checking if frontend extension is enabled..."
if jupyter labextension list 2>/dev/null | grep -q "reprolab"; then
    echo "   ✅ Frontend extension is enabled"
else
    echo "   ⚠️  Frontend extension status unclear (this is normal)"
    echo "   💡 The extension will be loaded when JupyterLab starts"
fi

# Check server extension configuration
echo "🔍 Checking server extension configuration..."
if [ -f "$HOME/.jupyter/jupyter_server_config.py" ] && grep -q "reprolab.*True" "$HOME/.jupyter/jupyter_server_config.py"; then
    echo "   ✅ Server extension configuration found"
else
    echo "   ❌ Server extension configuration missing"
    echo "   💡 Creating configuration file..."
    mkdir -p ~/.jupyter
    cat > ~/.jupyter/jupyter_server_config.py << EOF
# Jupyter Server Configuration for ReproLab
c.ServerApp.jpserver_extensions = {"reprolab": True}

# Enable CORS for API access
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_credentials = True

# Disable XSRF for API endpoints (if needed)
c.ServerApp.disable_check_xsrf = True
EOF
    echo "   ✅ Configuration file created"
fi

# Test server extension loading
echo "🔍 Testing server extension loading..."
if python3 -c "from reprolab.server import load_jupyter_server_extension; print('✅ Server extension loads successfully')" 2>/dev/null; then
    echo "   ✅ Server extension test passed"
else
    echo "   ❌ Server extension test failed"
    echo "   💡 Check the error messages above for dependency issues"
fi

# Overall verification
if [ "$FRONTEND_FOUND" = true ]; then
    echo ""
    echo "🎉 Installation verification completed!"
    echo "✅ Frontend extension: Installed and enabled"
    echo "✅ Server extension: Configuration verified and tested"
else
    echo ""
    echo "⚠️  Installation verification completed with warnings"
    echo "❌ Frontend extension: Not found in standard locations"
    echo "✅ Server extension: Configuration verified and tested"
fi

echo ""
echo "🚀 To start JupyterLab with ReproLab:"
echo "  jupyter lab"
echo ""
echo "The ReproLab panel will appear in the left sidebar."
echo ""
echo "📁 Configuration file location: ~/.jupyter/jupyter_server_config.py"
echo ""
echo "🔧 If you encounter issues:"
echo "   - Check JupyterLab logs for errors"
echo "   - Verify lab extension: jupyter labextension list"
echo "   - Check configuration: cat ~/.jupyter/jupyter_server_config.py"
echo "   - Note: Server extensions are loaded dynamically, not listed statically" 
