#!/bin/bash

# Script to copy built extension files to Safari Xcode project
# Run this from the repository root after building: cd linkwarden-official && npm run build && cd .. && ./copy-to-safari.sh

# Get the directory where this script is located (repository root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OFFICIAL_DIR="$SCRIPT_DIR/linkwarden-official"
SAFARI_PROJECT_DIR="$SCRIPT_DIR/Linkwarden for Safari/dist"

# Check if linkwarden-official exists
if [ ! -d "$OFFICIAL_DIR" ]; then
    echo "Error: linkwarden-official directory not found."
    echo "Please clone it first: git clone https://github.com/linkwarden/browser-extension.git linkwarden-official"
    exit 1
fi

# Check if dist folder exists in linkwarden-official
if [ ! -d "$OFFICIAL_DIR/dist" ]; then
    echo "Error: linkwarden-official/dist not found. Please build the extension first:"
    echo "  cd linkwarden-official"
    echo "  npm install"
    echo "  npm run build"
    exit 1
fi

# Check if Safari project directory exists
if [ ! -d "$SAFARI_PROJECT_DIR" ]; then
    echo "Error: Safari project directory not found at $SAFARI_PROJECT_DIR"
    exit 1
fi

# Copy manifest and background script
cp "$OFFICIAL_DIR/chromium/manifest.json" "$OFFICIAL_DIR/dist/manifest.json"
cp "$OFFICIAL_DIR/dist/manifest.json" "$SAFARI_PROJECT_DIR/manifest.json"
cp "$OFFICIAL_DIR/dist/background.js" "$SAFARI_PROJECT_DIR/background.js"

# Copy other built files
cp "$OFFICIAL_DIR/dist/main.js" "$SAFARI_PROJECT_DIR/main.js"
cp "$OFFICIAL_DIR/dist/options.js" "$SAFARI_PROJECT_DIR/options.js"
cp "$OFFICIAL_DIR/dist/index.html" "$SAFARI_PROJECT_DIR/index.html"

# Copy assets directory
rm -rf "$SAFARI_PROJECT_DIR/assets"
cp -r "$OFFICIAL_DIR/dist/assets" "$SAFARI_PROJECT_DIR/"

# Copy src directory (for options page)
rm -rf "$SAFARI_PROJECT_DIR/src"
cp -r "$OFFICIAL_DIR/dist/src" "$SAFARI_PROJECT_DIR/"

# Copy icons
cp "$OFFICIAL_DIR/dist"/*.png "$SAFARI_PROJECT_DIR/" 2>/dev/null || true

echo "✅ Files copied to Safari project successfully!"

