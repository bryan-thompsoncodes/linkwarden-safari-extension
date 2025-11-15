# Linkwarden for Safari

A Safari Web Extension for macOS and iOS that allows you to save bookmarks to your Linkwarden instance directly from Safari.

## Features

- ✅ Save links with title, description, URL, collection, and tags
- ✅ Upload screenshots of the current page
- ✅ Save all tabs in the current window
- ✅ Right-click context menu integration
- ✅ Two authentication methods: API key or Username/Password
- ✅ Works with both self-hosted and cloud-hosted Linkwarden instances
- ✅ Cross-device sync (settings sync via iCloud)

## Installation

### From App Store (Coming Soon)

The extension will be available on the App Store for macOS and iOS.

### From Source

1. **Prerequisites:**
   - macOS with Xcode installed
   - Apple Developer account (for code signing)
   - Node.js 18.x.x and npm 9.x.x (for building the extension)

2. **Clone the Official Extension:**
   ```bash
   # Clone the official extension repository (if not already cloned)
   git clone https://github.com/linkwarden/browser-extension.git linkwarden-official
   ```

3. **Build the Extension:**
   ```bash
   cd linkwarden-official
   npm install
   npm run build
   cd ..
   ./copy-to-safari.sh
   ```

4. **Open in Xcode:**
   - Open `Linkwarden for Safari.xcodeproj` in Xcode
   - Configure your bundle identifier and Apple Developer team
   - Build and run (⌘R)

5. **Enable in Safari:**
   - Safari → Settings → Extensions
   - Enable "Linkwarden for Safari Extension"
   - If needed, enable "Show features for web developers" in Safari → Settings → Advanced

## Usage

### Initial Setup

1. Click the Linkwarden icon in Safari's toolbar
2. Click "Settings" or go to Safari → Settings → Extensions → Linkwarden → Options
3. Enter your Linkwarden instance URL (e.g., `https://linkwarden.app` or your self-hosted URL)
4. Choose authentication method:
   - **API Key**: Enter your API key from Linkwarden settings
   - **Username/Password**: Enter your Linkwarden credentials
5. Click "Save"

### Saving Links

**Method 1: Popup**
- Click the Linkwarden icon in Safari's toolbar
- Review/edit the title, description, collection, and tags
- Click "Save"

**Method 2: Context Menu**
- Right-click on any link or page
- Select "Add link to Linkwarden"

**Method 3: Save All Tabs**
- Right-click on any page
- Select "Save all tabs to Linkwarden"

### Screenshots

When saving a link, check the "Upload Screenshot" option to capture and upload a screenshot of the current page.

## Known Limitations

These features from the Chrome/Firefox version are not available in Safari:

- **Bookmarks API**: Bookmark syncing feature is disabled (Safari doesn't support `browser.bookmarks`)
- **Omnibox**: Search via address bar keyword "lk" is disabled (Safari doesn't support omnibox)

All other features work identically to the Chrome/Firefox versions.

## Troubleshooting

### Extension Not Appearing in Safari

1. Make sure Developer mode is enabled:
   - Safari → Settings → Advanced
   - Check "Show features for web developers"

2. Check Extensions settings:
   - Safari → Settings → Extensions
   - Look for "Linkwarden for Safari Extension"
   - Enable it if it's disabled

3. Restart Safari completely and rebuild from Xcode

### CORS Errors

If you see CORS errors when connecting to a self-hosted instance:
- Ensure your Linkwarden instance allows requests from browser extensions
- The extension uses `fetch` API which should bypass CORS, but some server configurations may need adjustment

### Authentication Issues

- **API Key**: Make sure you're using a valid API key from Linkwarden Settings → API
- **Username/Password**: Ensure your credentials are correct
- Check that your Linkwarden instance URL doesn't have a trailing slash

### Build Errors

If you encounter build errors:
1. **Missing files error:** This is normal if you haven't run `copy-to-safari.sh` yet. Run it from the repository root.
2. **Missing `linkwarden-official` folder:** Clone it first: `git clone https://github.com/linkwarden/browser-extension.git linkwarden-official`
3. Clean build folder in Xcode (Shift+⌘+K)
4. Ensure all files are copied: Run `./copy-to-safari.sh` from the repository root
5. Check that bundle identifiers match between app and extension targets

## Development

### Project Structure

```
Linkwarden for Safari/
├── dist/                              # Built extension files
│   ├── manifest.json                  # Extension manifest
│   ├── background.js                  # Background service worker
│   ├── main.js                        # Popup script
│   ├── options.js                     # Settings page script
│   └── assets/                        # CSS and bundled JS
├── Linkwarden for Safari/            # macOS app wrapper
├── Linkwarden for Safari Extension/   # Extension target
└── Linkwarden for Safari.xcodeproj/  # Xcode project
```

### Updating from Official Extension

The Safari extension is based on the [official Linkwarden browser extension](https://github.com/linkwarden/browser-extension). To update:

1. Pull latest changes from the official extension:
   ```bash
   cd linkwarden-official
   git pull origin main
   ```

2. Review changes for Safari compatibility

3. Rebuild:
   ```bash
   npm run build
   cd ..
   ./copy-to-safari.sh
   ```

4. Test in Safari and update Xcode project if needed

### Building for Distribution

1. **Archive the app:**
   - In Xcode: Product → Archive
   - Wait for archive to complete

2. **Distribute:**
   - Click "Distribute App"
   - Choose distribution method (App Store, Ad Hoc, etc.)
   - Follow the prompts

3. **For TestFlight:**
   - Upload archive to App Store Connect
   - Add to TestFlight for beta testing

## Requirements

- **macOS**: 14.0 (Sonoma) or later
- **iOS**: 17.0 or later
- **Safari**: Latest version

## License

MIT License - See LICENSE file in the repository root.

## Credits

- Based on the [official Linkwarden browser extension](https://github.com/linkwarden/browser-extension)
- Converted to Safari Web Extension format
- Maintained by the community

## Support

For issues and feature requests related to the Safari extension, please open an issue in this repository.

For general Linkwarden issues, see the [main Linkwarden repository](https://github.com/linkwarden/linkwarden).

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on both macOS and iOS Safari
5. Submit a pull request

