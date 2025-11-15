# Safari-Specific Patches

This directory contains patches and files needed to make the official Linkwarden browser extension compatible with Safari.

## How It Works

Instead of modifying the official extension source directly (which would cause conflicts when pulling updates), we use a patch-based approach:

1. **Patches** - Git patch files that apply Safari-specific modifications
2. **Manifest** - Safari-compatible `manifest.json` (removes Safari-incompatible features)
3. **Build Script** - `build-for-safari.sh` applies patches, builds, then resets the official repo

## Patches

- **`auth-fetch.patch`** - Replaces `axios` with `fetch` API in `getSession()` for better Safari CORS compatibility
- **`cache-bookmarks.patch`** - Adds guards for `browser.bookmarks` API (not available in Safari)
- **`background-safari.patch`** - Adds guards for `browser.bookmarks` and `browser.omnibox` APIs in background script

## Manifest

- **`manifest-safari.json`** - Safari-compatible manifest that removes:
  - `bookmarks` permission
  - `omnibox` configuration
  - `type: "module"` from background (Safari handles this automatically)
  - `browser_style: false` from options_ui (not supported in Safari)

## Usage

Run the build script from the repository root:

```bash
./build-for-safari.sh
```

This will:
1. Reset the official repo to clean state
2. Apply all Safari patches
3. Copy Safari-compatible manifest
4. Build the extension
5. Copy files to Safari project
6. Reset the official repo back to clean state

## Updating Patches

If the official extension changes and patches no longer apply:

1. Make changes manually in `linkwarden-official/`
2. Test that it works
3. Generate new patches:
   ```bash
   cd linkwarden-official
   git diff src/@/lib/auth/auth.ts > ../safari-patches/auth-fetch.patch
   git diff src/@/lib/cache.ts > ../safari-patches/cache-bookmarks.patch
   git diff src/pages/Background/index.ts > ../safari-patches/background-safari.patch
   ```
4. Reset the official repo: `git checkout -- .`

## Why This Approach?

- ✅ Keeps official source clean and easy to update
- ✅ No merge conflicts when pulling upstream changes
- ✅ Patches are version-controlled and documented
- ✅ Easy to see what Safari-specific changes were made

