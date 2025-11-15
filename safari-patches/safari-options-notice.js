// Safari-specific notice injected into options page
// This script adds a notice about enabling website access in Safari settings
// It waits for React to fully render before injecting the notice

(function() {
  'use strict';
  
  let attemptCount = 0;
  const maxAttempts = 30; // Max 6 seconds (30 * 200ms)
  
  // Wait for window to be fully loaded and React to render
  function waitForReact() {
    attemptCount++;
    
    // Safety check - don't run forever
    if (attemptCount > maxAttempts) {
      return;
    }
    
    try {
      // Check if React has rendered by looking for the options container and its content
      const optionsContainer = document.getElementById('options');
      if (!optionsContainer || optionsContainer.children.length === 0) {
        setTimeout(waitForReact, 200);
        return;
      }
      
      // Check if notice already exists
      if (document.getElementById('safari-website-access-notice')) {
        return;
      }
      
      // Wait a bit more for React to fully render the form
      setTimeout(() => {
        try {
          // Look for the Container component with max-h class
          const container = optionsContainer.querySelector('div[class*="max-h"]');
          if (!container) {
            if (attemptCount < maxAttempts) {
              setTimeout(waitForReact, 200);
            }
            return;
          }
          
          // Find the description paragraph or separator to insert after
          const description = container.querySelector('p.text-base');
          const separator = container.querySelector('[class*="Separator"]');
          
          if (!description && !separator) {
            if (attemptCount < maxAttempts) {
              setTimeout(waitForReact, 200);
            }
            return;
          }
          
          // Create the notice element - no icon, just text to avoid any CSS conflicts
          const notice = document.createElement('div');
          notice.id = 'safari-website-access-notice';
          notice.style.cssText = 'margin-top: 1rem; padding: 1rem; background-color: rgb(254 252 232); border: 1px solid rgb(254 240 138); border-radius: 0.5rem; display: block;';
          
          // Add CSS to prevent any SVG or flex issues
          const preventSvgStyle = document.createElement('style');
          preventSvgStyle.textContent = `
            #safari-website-access-notice svg,
            #safari-website-access-notice * svg {
              display: none !important;
              width: 0 !important;
              height: 0 !important;
            }
            #safari-website-access-notice {
              display: block !important;
            }
            @media (prefers-color-scheme: dark) {
              #safari-website-access-notice {
                background-color: rgba(113, 63, 18, 0.2);
                border-color: rgb(113, 63, 18);
              }
            }
          `;
          document.head.appendChild(preventSvgStyle);
          
          notice.innerHTML = `
            <h3 style="font-size: 0.875rem; font-weight: 600; color: rgb(113, 63, 18); margin-bottom: 0.25rem;">
              Enable Website Access
            </h3>
            <p style="font-size: 0.875rem; color: rgb(113, 63, 18); margin-bottom: 0.5rem;">
              If you're having trouble connecting to your Linkwarden server, you may need to enable website access for this extension:
            </p>
            <ol style="font-size: 0.875rem; color: rgb(113, 63, 18); list-style: decimal; list-style-position: inside; margin-left: 0.5rem;">
              <li style="margin-bottom: 0.25rem;">Open Safari → Settings (or Preferences)</li>
              <li style="margin-bottom: 0.25rem;">Go to Extensions</li>
              <li style="margin-bottom: 0.25rem;">Select "Linkwarden for Safari Extension"</li>
              <li style="margin-bottom: 0.25rem;">Enable "Allow access to all websites"</li>
            </ol>
          `;
          
          // Insert after the description paragraph's parent div
          const insertAfter = description ? description.parentElement : separator.parentElement;
          if (insertAfter && insertAfter.parentElement) {
            if (insertAfter.nextSibling) {
              insertAfter.parentElement.insertBefore(notice, insertAfter.nextSibling);
            } else {
              insertAfter.parentElement.appendChild(notice);
            }
          }
        } catch (error) {
          // Silently fail if there's an error - don't break the page
          console.error('Error adding Safari notice:', error);
        }
      }, 500);
    } catch (error) {
      // Silently fail - don't break the page
      console.error('Error in Safari notice script:', error);
    }
  }
  
  // Start after everything is loaded - use a longer delay to ensure React is ready
  setTimeout(() => {
    if (document.readyState === 'complete') {
      waitForReact();
    } else {
      window.addEventListener('load', () => {
        setTimeout(waitForReact, 1000);
      });
    }
  }, 1000);
})();

