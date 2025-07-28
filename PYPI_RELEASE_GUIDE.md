# PyPI Release Guide for ReproLab

This guide explains how to release ReproLab to PyPI so users can install it with `pip install reprolab`.

## Prerequisites

1. **PyPI Account**: Create an account on [PyPI](https://pypi.org/account/register/)
2. **Test PyPI Account**: Create an account on [Test PyPI](https://test.pypi.org/account/register/)
3. **API Tokens**: Generate API tokens for both PyPI and Test PyPI
4. **Build Tools**: Install required build tools

```bash
pip install build twine
```

## Release Process

### 1. Prepare for Release

Before releasing, ensure:
- [ ] All tests pass
- [ ] Frontend extension builds successfully
- [ ] Version number is updated in `package.json`
- [ ] CHANGELOG.md is updated
- [ ] README.md is up to date

### 2. Build the Package

Run the release script:

```bash
./release_to_pypi.sh
```

This script will:
- Clean previous builds
- Build the frontend extension
- Build the Python package
- Check the package for issues

### 3. Test on Test PyPI

First, test the release on Test PyPI:

```bash
python3 -m twine upload --repository testpypi dist/*
```

Install and test from Test PyPI:

```bash
pip install --index-url https://test.pypi.org/simple/ reprolab
```

### 4. Release to PyPI

If the test is successful, release to PyPI:

```bash
python3 -m twine upload dist/*
```

### 5. Verify Installation

Test the installation:

```bash
pip install reprolab
python -c "import reprolab; print('ReproLab installed successfully!')"
```

## Package Structure

The package includes:
- **Python backend**: Server extension and experiment management
- **Frontend extension**: JupyterLab UI components
- **Dependencies**: All required packages for virtual environment creation

## Installation for End Users

Once released, users can install ReproLab with:

```bash
pip install reprolab
```

Then start JupyterLab:

```bash
jupyter lab
```

The ReproLab panel will appear in the left sidebar, and users can create new experiment environments that automatically include ReproLab.

## Version Management

- Update version in `package.json`
- The Python version is automatically synced from the Node.js version
- Use semantic versioning (MAJOR.MINOR.PATCH)

## Troubleshooting

### Common Issues

1. **Build fails**: Ensure all dependencies are installed
2. **Upload fails**: Check API tokens and credentials
3. **Import errors**: Verify package structure and entry points

### Testing Locally

Test the package locally before release:

```bash
pip install -e .
python -c "import reprolab; print('Local installation works')"
```

## Security

- Never commit API tokens to version control
- Use environment variables for credentials
- Test thoroughly on Test PyPI before main PyPI release 
