#!/bin/bash

# Script to copy built extension files to Safari Xcode project
# Run this from the repository root after building: cd linkwarden-official && npm run build && cd .. && ./copy-to-safari.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OFFICIAL_DIR="$SCRIPT_DIR/linkwarden-official"
SAFARI_PROJECT_DIR="$SCRIPT_DIR/Linkwarden for Safari/dist"
PATCHES_DIR="$SCRIPT_DIR/safari-patches"

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

# Create Safari project directory if it doesn't exist
if [ ! -d "$SAFARI_PROJECT_DIR" ]; then
    echo "Creating Safari project directory at $SAFARI_PROJECT_DIR"
    mkdir -p "$SAFARI_PROJECT_DIR"
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

# Fix background.js for Safari - wrap omnibox and bookmarks API calls
BACKGROUND_JS="$SAFARI_PROJECT_DIR/background.js"
if [ -f "$BACKGROUND_JS" ]; then
    echo "  ✓ Fixing background.js for Safari compatibility..."
    node -e "
        const fs = require('fs');
        const bg = fs.readFileSync('$BACKGROUND_JS', 'utf8');
        let fixed = bg;

        // Fix omnibox API calls
        if (bg.includes('t.omnibox') && !bg.includes('if(t.omnibox)')) {
            const startIdx = bg.indexOf('t.omnibox.onInputStarted');
            if (startIdx !== -1) {
                let endIdx = bg.length;
                for (let i = bg.length - 1; i >= startIdx; i--) {
                    if (bg.substring(i, i + 3) === '});') {
                        endIdx = i + 3;
                        break;
                    }
                }
                const before = bg.substring(0, startIdx);
                const omnibox = bg.substring(startIdx, endIdx);
                const after = bg.substring(endIdx);
                fixed = before + 'if(t.omnibox){' + omnibox + '}' + after;
                console.log('    Wrapped omnibox API calls in Safari guard');
            }
        }

        // Fix bookmarks API calls
        if (fixed.includes('t.bookmarks.create') && !fixed.includes('t.bookmarks&&')) {
            fixed = fixed.replace(/if\(s\)t\.bookmarks\.create/g, 'if(s&&t.bookmarks)t.bookmarks.create');
            console.log('    Wrapped bookmarks API calls in Safari guard');
        }

        if (fixed !== bg) {
            fs.writeFileSync('$BACKGROUND_JS', fixed, 'utf8');
        } else {
            console.log('    Background.js already has all Safari guards');
        }
    "
fi

# Inject Safari-specific notice script into options page
if [ -f "$PATCHES_DIR/safari-options-notice.js" ]; then
    echo "  ✓ Injecting Safari options notice..."
    OPTIONS_HTML="$SAFARI_PROJECT_DIR/src/pages/Options/options.html"
    if [ -f "$OPTIONS_HTML" ] && ! grep -q "safari-options-notice.js" "$OPTIONS_HTML"; then
        cp "$PATCHES_DIR/safari-options-notice.js" "$SAFARI_PROJECT_DIR/assets/safari-options-notice.js"
        TEMP_FILE=$(mktemp)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed '/<\/body>/i\
  <script defer src="/assets/safari-options-notice.js"></script>
' "$OPTIONS_HTML" > "$TEMP_FILE"
        else
            sed '/<\/body>/i\  <script defer src="/assets/safari-options-notice.js"></script>' "$OPTIONS_HTML" > "$TEMP_FILE"
        fi
        mv "$TEMP_FILE" "$OPTIONS_HTML"
    fi
fi

echo "✅ Files copied to Safari project successfully!"