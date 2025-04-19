# Changes - Window Toggle by Title

## Summary
Added a new WindowToggler module that allows toggling windows between their current position and the "nearlyFull" layout with positions remembered by window title.

## Feature Details
- **WindowToggler Module**: A new module for toggling window positions by title
  - Saves position when toggling to "nearlyFull" layout
  - Restores saved position when toggling again
  - Tracks windows by title, allowing recognition of the same window across application restarts
  - Detects if a window is already in the "nearlyFull" layout position (with margin of error)

## New Files
- `WindowToggler.lua`: Core module implementation
- `WindowToggler_README.md`: Documentation for the feature

## Changes to Existing Files
- `hotkeys.lua`: Added import for WindowToggler module and hotkeys for the new functionality
  - `hammer+w`: Toggle current window position
  - `hyper+w`: List saved window positions
  - `hammer+q`: Clear all saved window positions
- `README.md`: Updated to include information about the new WindowToggler module

## Implementation Notes
- Positions are stored in a table keyed by window title
- The module checks if a window is in "nearlyFull" layout by comparing its position to the nearlyFull layout dimensions with a small margin of error
- Used HyperLogger for consistent logging

## Lessons Learned
- Window titles offer a more persistent way to track windows than window IDs, which change when applications restart
- Position comparison with a margin of error is necessary due to small variations in window positioning
- This approach could be extended to other layout types in the future

## Next Steps
- Consider adding persistence between Hammerspoon restarts by saving positions to a JSON file
- Add support for multiple remembered positions per window title
- Consider integrating with the existing WindowManager module more deeply 
