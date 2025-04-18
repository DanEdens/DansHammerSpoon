# HammerGhost Development Plan

## Analysis of EventGhost UI
- Tree-based structure for organizing automation elements
- Dark theme with professional appearance
- Hierarchical organization of items
- Clear visual indicators for different item types
- Interactive elements (expand/collapse, hover effects)

## Core Requirements

### UI Components
- Main window with dark theme matching EventGhost
- Tree view with proper indentation and visual hierarchy
- Split panel design (tree view + properties)
- Toolbar for common actions
- Context menus for item manipulation

### Item Types
- 📁/📂 Folders: Organizational containers
- ⚡ Actions: Single automation steps
- ⚙️ Sequences: Multiple steps in sequence
- Visual indicators for enabled/disabled states
- Hover effects showing available actions

### Core Functionality
- Create/Edit/Delete operations for all item types
- Drag-and-drop reordering
- Expandable/collapsible tree nodes
- Persistent storage of configurations
- Undo/Redo support
- Copy/Paste operations

## Technical Implementation

### Data Structure
```xml
<HammerGhost version="1.0">
  <Folder name="My Macros">
    <Enabled>True</Enabled>
    <Action name="Launch Application">
      <Enabled>True</Enabled>
      <Config>
        <Application>Terminal</Application>
        <Arguments></Arguments>
      </Config>
    </Action>
    <Sequence name="Work Setup">
      <Enabled>True</Enabled>
      <Action name="Launch Browser">
        <Config>
          <URL>https://github.com</URL>
        </Config>
      </Action>
      <Action name="Arrange Windows">
        <Config>
          <Layout>coding</Layout>
        </Config>
      </Action>
    </Sequence>
  </Folder>
</HammerGhost>
```

### Storage Layer
- XML-based persistence (similar to EventGhost format)
- LXML or similar for Lua XML parsing
- Auto-save functionality with backup
- Version attribute for future migrations
- Pretty-printed format for readability
- XPath support for efficient querying

### UI Implementation
- hs.webview for main interface
- HTML/CSS/JS for tree view
- Custom toolbar integration
- Dark theme implementation
- Responsive layout

## TODO Steps

### Phase 1: Foundation
- [ ] Set up basic window structure
- [ ] Implement dark theme
- [ ] Create data structure
- [ ] Add JSON storage system
- [ ] Basic tree view implementation

### Phase 2: Core Features
- [ ] Add item creation functionality
- [ ] Implement drag-and-drop
- [ ] Add context menus
- [ ] Create property panel
- [ ] Implement item editing

### Phase 3: Advanced Features
- [ ] Add undo/redo system
- [ ] Implement copy/paste
- [ ] Add keyboard shortcuts
- [ ] Create search functionality
- [ ] Add import/export features

### Phase 4: Polish
- [ ] Add animations
- [ ] Improve error handling
- [ ] Add loading indicators
- [ ] Create help documentation
- [ ] Add tooltips and hints

## Integration Points

### Hammerspoon Integration
- Spoon architecture compatibility
- Event handling system
- Hotkey management
- System API access

### Existing Code Analysis
- Current HammerGhost.spoon structure
- Available UI components
- Event handling patterns
- Storage mechanisms

## Future Considerations
- Plugin system
- Remote control capabilities
- Multi-monitor support
- Backup/restore functionality
- Performance optimization for large configurations

## Spoon-Specific Requirements

### API Conventions
- Follow TitleCase for Spoon name (HammerGhost)
- Use camelCase for methods/variables/constants
- Implement standard lifecycle methods:
  ```lua
  HammerGhost:init()    -- Called automatically by hs.loadSpoon()
  HammerGhost:start()   -- Start background activities
  HammerGhost:stop()    -- Stop background activities
  HammerGhost:bindHotkeys(mapping) -- Configure hotkeys
  ```

### Required Metadata
```lua
HammerGhost = {
  name = "HammerGhost",
  version = "1.0",
  author = "Your Name <email@example.com>",
  license = "MIT - https://opensource.org/licenses/MIT",
  homepage = "https://github.com/yourusername/HammerGhost.spoon"
}
```

### File Structure
```
HammerGhost.spoon/
├── init.lua           -- Main Spoon code
├── docs.json         -- Generated API documentation
├── README.md         -- Usage instructions
└── assets/           -- Resources directory
    ├── images/       -- Icons and images
    └── scripts/      -- Additional Lua scripts
```

### Resource Loading
```lua
-- Get Spoon path
obj.spoonPath = hs.spoons.scriptPath()

-- Load assets
obj.imagePath = hs.spoons.resourcePath("images/icon.png")

-- Load additional code
dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))
```

### Documentation Requirements
- Use Hammerspoon-style docstrings for all public APIs
- Generate docs.json using hs.doc.builder
- Include example configurations
- Document all hotkey-bindable actions

## Development Guidelines
1. Maintain consistent dark theme throughout
2. Ensure responsive UI performance
3. Follow Hammerspoon best practices
4. Implement proper error handling
5. Add detailed logging for debugging
6. Create comprehensive documentation
7. Follow Spoons API conventions strictly
8. Use hs.spoons.bindHotkeysToSpec() for hotkey binding
9. Implement proper resource loading using hs.spoons methods
10. Generate and maintain up-to-date documentation

## Testing Strategy
- Unit tests for core functionality
- UI interaction tests
- Storage system validation
- Performance benchmarks
- Cross-platform verification

## Documentation Needs
- User guide
- API documentation
- Configuration guide
- Troubleshooting guide
- Development setup instructions



## Jan 16
XML Handling:
The XML parser is loaded but we're not fully using it yet
Need to implement proper XML saving/loading for configuration persistence
Currently commented out in the init() function
Properties Panel:
The right-side panel is created but not fully functional
Need to implement updateProperty function for editing properties
Add more properties based on item type (action parameters, sequence steps, etc.)
3. Action/Sequence Functionality:
Need to implement actual functionality for actions
Need to implement sequence step management
Add ability to record/edit action parameters
Add ability to reorder sequence steps
Drag and Drop:
Add ability to drag items to reorder them
Add ability to drag items into folders
Add visual feedback during drag operations
Context Menu:
Right-click menu for additional operations
Copy/Paste functionality
Enable/Disable items
Import/Export functionality
Keyboard Navigation:
Arrow key navigation in the tree
Keyboard shortcuts for common operations
Tab navigation between panels
Error Handling:
Better error messages
Recovery from invalid configurations
Backup of configuration before changes
