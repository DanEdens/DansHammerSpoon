# Window Toggler

A Hammerspoon module that allows toggling windows between their current position and a "nearlyFull" layout. The module keeps track of window positions by title, allowing each window to remember its previous position.

## Features

- Toggle windows between their current position and a nearlyFull layout
- Positions are remembered by window title, not just window ID
- List all currently saved window positions
- Clear all saved window positions

## Hotkeys

| Key Combination | Action | Description |
|----------------|--------|-------------|
| `hammer + w` | Toggle Window Position | Toggle the current window between its current position and a nearlyFull layout |
| `hyper + w` | List Saved Windows | Show a list of all window titles with saved positions |
| `hammer + q` | Clear Saved Positions | Clear all saved window positions |

## How It Works

1. When you press `hammer + w` on a window for the first time:
   - The window's current position is saved
   - The window is moved to a nearlyFull layout (80% of the screen, centered)

2. When you press `hammer + w` on a window that's in the nearlyFull layout:
   - The window is moved back to its previously saved position

3. When you press `hammer + w` on a window that's not in the nearlyFull layout:
   - The window's current position is saved (overwriting the previous position)
   - The window is moved to a nearlyFull layout

## Implementation Details

Window positions are stored in a table keyed by window title. This means the positions persist even if the window is closed and reopened, as long as it has the same title.

A threshold-based approach is used to determine if a window is "nearlyFull" - it checks if the window's current position is within a small margin of the nearlyFull layout dimensions. 
