#!/bin/bash
# Setup script for rust-docs-it development environment
# Run from project root: bash dev-setup/setup-dev.sh

set -e

echo "🦀 Setting up Rust Docs IT development environment..."

# Ensure we're in the project root
if [ ! -f "mkdocs.yml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "   Usage: bash dev-setup/setup-dev.sh"
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate || source venv/Scripts/activate

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install pre-commit hooks
echo "🪝 Installing pre-commit hooks..."
pip install pre-commit
pre-commit install

# Check markdownlint availability (requires npm/node)
if command -v npm &> /dev/null; then
    echo "📝 markdownlint disponibile via npx"
    echo "   Usa: npx markdownlint-cli '**/*.md'"
else
    echo "⚠️  npm non trovato. Markdownlint non disponibile."
    echo "   Installa Node.js >= 20 per abilitare markdown linting."
fi

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Activate the environment: source venv/bin/activate (or venv\\Scripts\\activate on Windows)"
echo "  2. Start the dev server: mkdocs serve"
echo "  3. Open http://127.0.0.1:8000 in your browser"
echo ""
echo "Pre-commit hooks are now active! They will run automatically on 'git commit'."
echo "To manually run all hooks: pre-commit run --all-files"
echo ""
