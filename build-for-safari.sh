#!/bin/bash

# Build script for Safari extension that keeps official source clean
# This script applies Safari-specific patches, builds, then resets the official repo

set -e  # Exit on error

# Get the directory where this script is located (repository root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OFFICIAL_DIR="$SCRIPT_DIR/linkwarden-official"
PATCHES_DIR="$SCRIPT_DIR/safari-patches"
SAFARI_PROJECT_DIR="$SCRIPT_DIR/Linkwarden for Safari/dist"

# Check if linkwarden-official exists
if [ ! -d "$OFFICIAL_DIR" ]; then
    echo "Error: linkwarden-official directory not found."
    echo "Please clone it first: git clone https://github.com/linkwarden/browser-extension.git linkwarden-official"
    exit 1
fi

# Check if patches directory exists
if [ ! -d "$PATCHES_DIR" ]; then
    echo "Error: safari-patches directory not found."
    exit 1
fi

echo "🔧 Applying Safari-specific patches..."

# Navigate to official directory
cd "$OFFICIAL_DIR"

# Ensure we're on a clean state (reset any local changes)
echo "📦 Resetting to clean state..."
git checkout -- . 2>/dev/null || true

# Apply patches
if [ -f "$PATCHES_DIR/auth-fetch.patch" ]; then
    echo "  ✓ Applying auth-fetch.patch..."
    git apply "$PATCHES_DIR/auth-fetch.patch" || {
        echo "  ⚠ Warning: auth-fetch.patch may have conflicts. Check manually."
    }
fi

if [ -f "$PATCHES_DIR/cache-bookmarks.patch" ]; then
    echo "  ✓ Applying cache-bookmarks.patch..."
    git apply "$PATCHES_DIR/cache-bookmarks.patch" || {
        echo "  ⚠ Warning: cache-bookmarks.patch may have conflicts. Check manually."
    }
fi

if [ -f "$PATCHES_DIR/background-safari.patch" ]; then
    echo "  ✓ Applying background-safari.patch..."
    git apply "$PATCHES_DIR/background-safari.patch" || {
        echo "  ⚠ Warning: background-safari.patch may have conflicts. Check manually."
    }
fi

# Copy Safari-compatible manifest
if [ -f "$PATCHES_DIR/manifest-safari.json" ]; then
    echo "  ✓ Copying Safari-compatible manifest..."
    cp "$PATCHES_DIR/manifest-safari.json" "$OFFICIAL_DIR/chromium/manifest.json"
fi

echo "🔨 Installing dependencies..."
npm install

echo "🔨 Building extension..."
npm run build

# Copy to Safari project
echo "📋 Copying files to Safari project..."
cd "$SCRIPT_DIR"
./copy-to-safari.sh

# Reset official repo to clean state
echo "🧹 Resetting official repo to clean state..."
cd "$OFFICIAL_DIR"
git checkout -- . 2>/dev/null || true

echo "✅ Build complete! Official source is clean."
echo ""
echo "Next steps:"
echo "  1. Open Xcode: open 'Linkwarden for Safari/Linkwarden for Safari.xcodeproj'"
echo "  2. Build and run (⌘R)"

