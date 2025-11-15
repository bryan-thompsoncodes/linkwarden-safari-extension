// Post-build script to fix background.js for Safari compatibility
// This wraps omnibox API calls in a guard since Safari doesn't support omnibox

const fs = require('fs');
const path = require('path');

const backgroundJsPath = process.argv[2];

if (!backgroundJsPath) {
  console.error('Usage: node fix-background-omnibox.js <path-to-background.js>');
  process.exit(1);
}

let backgroundCode = fs.readFileSync(backgroundJsPath, 'utf8');

// Check if already fixed
if (backgroundCode.includes('if(t.omnibox)') || backgroundCode.includes('if(browser.omnibox)')) {
  console.log('Background script already has omnibox guard');
  process.exit(0);
}

// Find omnibox usage patterns in minified code
// Pattern: t.omnibox.onInputStarted, t.omnibox.onInputChanged, t.omnibox.onInputEntered, t.omnibox.setDefaultSuggestion

// Wrap omnibox calls - look for the pattern where omnibox is used
// Since the code is minified, we need to find where omnibox listeners start and end

// Strategy: Find all omnibox references and wrap them
// The minified code structure is: t.omnibox.onInputStarted.addListener(...)

// Try to wrap the omnibox section
// Look for pattern: t.omnibox.onInputStarted
const omniboxStartPattern = /(t\.omnibox\.onInputStarted)/;
const omniboxEndPattern = /(\);?\s*$)/m;

if (omniboxStartPattern.test(backgroundCode)) {
  // Find the start of omnibox usage
  const startMatch = backgroundCode.match(/(t\.omnibox\.onInputStarted)/);
  if (startMatch) {
    const startIndex = startMatch.index;
    
    // Find where the last omnibox call ends - look for the closing of onInputEntered
    // The pattern should be: t.omnibox.onInputEntered.addListener(...) followed by });
    const omniboxSection = backgroundCode.substring(startIndex);
    
    // Find the end of the last omnibox listener
    // Look for the pattern that ends the onInputEntered listener
    let braceCount = 0;
    let inString = false;
    let stringChar = null;
    let endIndex = startIndex;
    
    for (let i = startIndex; i < backgroundCode.length; i++) {
      const char = backgroundCode[i];
      const prevChar = i > 0 ? backgroundCode[i - 1] : '';
      
      if (!inString && (char === '"' || char === "'" || char === '`')) {
        inString = true;
        stringChar = char;
      } else if (inString && char === stringChar && prevChar !== '\\') {
        inString = false;
        stringChar = null;
      } else if (!inString) {
        if (char === '(') braceCount++;
        if (char === ')') braceCount--;
        if (char === '}' && braceCount === 0) {
          // Check if this is the end of the omnibox section
          // Look ahead to see if there's another omnibox call
          const remaining = backgroundCode.substring(i + 1);
          if (!remaining.includes('omnibox')) {
            endIndex = i + 1;
            break;
          }
        }
      }
    }
    
    // Wrap the omnibox section
    const beforeOmnibox = backgroundCode.substring(0, startIndex);
    const omniboxCode = backgroundCode.substring(startIndex, endIndex);
    const afterOmnibox = backgroundCode.substring(endIndex);
    
    // Add guard - in minified code, 't' is the browser object
    const fixedCode = beforeOmnibox + 
      'if(t.omnibox){' + omniboxCode + '}' + 
      afterOmnibox;
    
    fs.writeFileSync(backgroundJsPath, fixedCode, 'utf8');
    console.log('Fixed background.js: Wrapped omnibox API calls in Safari guard');
  } else {
    console.log('Could not find omnibox usage pattern');
  }
} else {
  console.log('No omnibox usage found in background.js');
}

