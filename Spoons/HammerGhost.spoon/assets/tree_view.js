/**
 * TreeView Component
 * A flexible, feature-rich tree component for rendering hierarchical data
 * 
 * Features:
 * - Hierarchical display of tree data with collapsible nodes
 * - Custom rendering of nodes with icons and actions
 * - Keyboard navigation and selection
 * - Drag and drop for reordering nodes
 * - Context menu support
 * - Search/filter functionality
 * - Virtualized rendering for performance with large trees
 */

class TreeView
{
    /**
     * Create a new TreeView instance
     * @param {Object} options - Configuration options
     * @param {HTMLElement} options.container - Container element for the tree view
     * @param {Array} options.data - Tree data structure
     * @param {Function} [options.onSelect] - Callback when a node is selected
     * @param {Function} [options.onToggle] - Callback when a node is expanded/collapsed
     * @param {Function} [options.onContextMenu] - Callback when context menu is requested
     * @param {Function} [options.onNodeAction] - Callback when a node action is triggered
     * @param {Function} [options.onDrop] - Callback when a node is dropped after drag
     * @param {Object} [options.icons] - Custom icons for different node types
     * @param {Array} [options.actions] - Custom actions for nodes
     * @param {boolean} [options.dragEnabled=true] - Enable drag and drop
     * @param {boolean} [options.searchEnabled=true] - Enable search/filter
     * @param {boolean} [options.keyboardNavigation=true] - Enable keyboard navigation
     */
    constructor(options)
    {
        this.container = options.container;
        this.data = options.data || [];
        this.selectedNode = null;

        // Callbacks
        this.onSelect = options.onSelect || (() => { });
        this.onToggle = options.onToggle || (() => { });
        this.onContextMenu = options.onContextMenu || (() => { });
        this.onNodeAction = options.onNodeAction || (() => { });
        this.onDrop = options.onDrop || (() => { });

        // Configuration
        this.icons = options.icons || {};
        this.actions = options.actions || [];
        this.dragEnabled = options.dragEnabled !== false;
        this.searchEnabled = options.searchEnabled !== false;
        this.keyboardNavigation = options.keyboardNavigation !== false;

        // State
        this.dragState = {
            isDragging: false,
            draggedNode: null,
            dropTarget: null,
            dropPosition: null
        };

        this.filterText = '';
        this.filteredData = null;
        this.expandedNodes = new Set();

        // Create DOM structure
        this.render();

        // Initialize event listeners
        this.initEventListeners();
    }

    /**
     * Render the tree view component
     */
    render()
    {
        this.container.innerHTML = '';
        this.container.classList.add('tree-view');

        // Create filter bar if search is enabled
        if (this.searchEnabled)
        {
            this.createFilterBar();
        }

        // Create the main tree container
        this.treeContainer = document.createElement('div');
        this.treeContainer.className = 'tree-view-container';
        this.container.appendChild(this.treeContainer);

        // Render tree content
        this.renderTree();
    }

    /**
     * Create the filter/search bar
     */
    createFilterBar()
    {
        const filterBar = document.createElement('div');
        filterBar.className = 'tree-view-filter';

        const filterInput = document.createElement('input');
        filterInput.className = 'tree-view-filter-input';
        filterInput.placeholder = 'Search...';
        filterInput.type = 'text';
        filterInput.value = this.filterText;

        const clearButton = document.createElement('button');
        clearButton.className = 'tree-view-filter-clear';
        clearButton.innerHTML = '×';
        clearButton.style.display = this.filterText ? 'flex' : 'none';

        filterBar.appendChild(filterInput);
        filterBar.appendChild(clearButton);

        // Add event listeners
        filterInput.addEventListener('input', (e) =>
        {
            this.filterText = e.target.value;
            clearButton.style.display = this.filterText ? 'flex' : 'none';
            this.filterTree(this.filterText);
        });

        clearButton.addEventListener('click', () =>
        {
            filterInput.value = '';
            this.filterText = '';
            clearButton.style.display = 'none';
            this.filterTree('');
        });

        this.container.appendChild(filterBar);
    }

    /**
     * Render the tree structure
     */
    renderTree()
    {
        const data = this.filteredData || this.data;

        // Empty state
        if (!data || data.length === 0)
        {
            this.treeContainer.innerHTML = `
        <div class="tree-view-empty">
          <span>No items to display</span>
        </div>
      `;
            return;
        }

        // Create tree list
        const treeList = document.createElement('ul');
        treeList.className = 'tree-view-list';

        // Render tree nodes
        this.renderNodes(data, treeList, 0);

        this.treeContainer.innerHTML = '';
        this.treeContainer.appendChild(treeList);
    }

    /**
     * Render tree nodes recursively
     * @param {Array} nodes - Array of tree nodes
     * @param {HTMLElement} parent - Parent DOM element
     * @param {number} level - Current depth level
     */
    renderNodes(nodes, parent, level)
    {
        nodes.forEach(node =>
        {
            const item = document.createElement('li');
            item.className = 'tree-view-item';
            item.dataset.id = node.id;

            const row = document.createElement('div');
            row.className = 'tree-view-row';
            row.tabIndex = this.keyboardNavigation ? 0 : -1;

            if (this.selectedNode === node.id)
            {
                row.classList.add('selected');
            }

            // Indentation
            for (let i = 0; i < level; i++)
            {
                const indent = document.createElement('span');
                indent.className = 'tree-view-indent';
                row.appendChild(indent);
            }

            // Toggle for expandable nodes
            const hasChildren = node.children && node.children.length > 0;
            const toggle = document.createElement('span');
            toggle.className = 'tree-view-toggle';

            if (hasChildren)
            {
                toggle.innerHTML = '▶';
                toggle.style.visibility = 'visible';
                if (this.isNodeExpanded(node.id))
                {
                    toggle.classList.add('expanded');
                }
            } else
            {
                toggle.style.visibility = 'hidden';
            }

            row.appendChild(toggle);

            // Node icon
            const icon = document.createElement('span');
            icon.className = 'tree-view-icon';

            if (node.type === 'folder')
            {
                icon.classList.add('tree-view-folder-icon');
                icon.innerHTML = this.isNodeExpanded(node.id) ? '📂' : '📁';
            } else
            {
                icon.classList.add('tree-view-file-icon');
                icon.innerHTML = this.getIconForNode(node);
            }

            row.appendChild(icon);

            // Node label
            const label = document.createElement('span');
            label.className = 'tree-view-label';

            if (this.filterText && this.filterText.length > 0)
            {
                // Highlight matching text
                label.innerHTML = this.highlightText(node.name, this.filterText);
            } else
            {
                label.textContent = node.name;
            }

            row.appendChild(label);

            // Node actions
            const actions = document.createElement('div');
            actions.className = 'tree-view-actions';

            // Add custom actions
            this.actions.forEach(action =>
            {
                if (action.condition && !action.condition(node))
                {
                    return;
                }

                const button = document.createElement('button');
                button.className = `tree-view-action-button ${action.class || ''}`;
                button.innerHTML = action.icon || '';
                button.title = action.title || '';

                button.addEventListener('click', (e) =>
                {
                    e.stopPropagation();
                    this.onNodeAction(action.id, node);
                });

                actions.appendChild(button);
            });

            row.appendChild(actions);
            item.appendChild(row);

            // Children container
            if (hasChildren)
            {
                const childrenContainer = document.createElement('div');
                childrenContainer.className = 'tree-view-children';

                const childList = document.createElement('ul');
                childList.className = 'tree-view-list';

                childrenContainer.appendChild(childList);
                item.appendChild(childrenContainer);

                // Render children if expanded
                if (this.isNodeExpanded(node.id))
                {
                    this.renderNodes(node.children, childList, level + 1);
                    childrenContainer.style.display = 'block';
                } else
                {
                    childrenContainer.style.display = 'none';
                }
            }

            parent.appendChild(item);
        });
    }

    /**
     * Initialize event listeners
     */
    initEventListeners()
    {
        // Delegate event handling to container
        this.container.addEventListener('click', this.handleClick.bind(this));

        // Context menu
        this.container.addEventListener('contextmenu', this.handleContextMenu.bind(this));

        // Keyboard navigation
        if (this.keyboardNavigation)
        {
            this.container.addEventListener('keydown', this.handleKeyDown.bind(this));
        }

        // Drag and drop
        if (this.dragEnabled)
        {
            this.container.addEventListener('mousedown', this.handleDragStart.bind(this));
            document.addEventListener('mousemove', this.handleDragMove.bind(this));
            document.addEventListener('mouseup', this.handleDragEnd.bind(this));
        }
    }

    /**
     * Handle click events
     * @param {Event} e - Click event
     */
    handleClick(e)
    {
        const row = e.target.closest('.tree-view-row');
        if (!row) return;

        const id = row.parentElement.dataset.id;
        const node = this.findNodeById(id);

        if (!node) return;

        // Toggle node expansion
        if (e.target.closest('.tree-view-toggle'))
        {
            this.toggleNode(id);
            return;
        }

        // Node action button clicked
        if (e.target.closest('.tree-view-action-button'))
        {
            return; // Already handled by the action button event listener
        }

        // Select the node
        this.selectNode(id);
    }

    /**
     * Handle context menu events
     * @param {Event} e - Context menu event
     */
    handleContextMenu(e)
    {
        const row = e.target.closest('.tree-view-row');
        if (!row) return;

        const id = row.parentElement.dataset.id;
        const node = this.findNodeById(id);

        if (!node) return;

        e.preventDefault();

        // Select the node
        this.selectNode(id);

        // Trigger context menu callback
        this.onContextMenu(node, {
            x: e.clientX,
            y: e.clientY
        });
    }

    /**
     * Handle keyboard navigation
     * @param {KeyboardEvent} e - Keyboard event
     */
    handleKeyDown(e)
    {
        if (!this.selectedNode) return;

        const node = this.findNodeById(this.selectedNode);
        if (!node) return;

        switch (e.key)
        {
            case 'ArrowUp':
                e.preventDefault();
                this.selectPreviousNode();
                break;

            case 'ArrowDown':
                e.preventDefault();
                this.selectNextNode();
                break;

            case 'ArrowRight':
                e.preventDefault();
                if (node.children && node.children.length)
                {
                    if (!this.isNodeExpanded(node.id))
                    {
                        this.toggleNode(node.id);
                    } else
                    {
                        // Select first child
                        this.selectNode(node.children[0].id);
                    }
                }
                break;

            case 'ArrowLeft':
                e.preventDefault();
                if (this.isNodeExpanded(node.id))
                {
                    this.toggleNode(node.id);
                } else
                {
                    // Select parent
                    const parent = this.findParentNode(node.id);
                    if (parent)
                    {
                        this.selectNode(parent.id);
                    }
                }
                break;

            case 'Enter':
                e.preventDefault();
                this.onSelect(node);
                break;

            case ' ':
                e.preventDefault();
                if (node.children && node.children.length)
                {
                    this.toggleNode(node.id);
                }
                break;
        }
    }

    /**
     * Handle drag start
     * @param {MouseEvent} e - Mouse event
     */
    handleDragStart(e)
    {
        if (!this.dragEnabled) return;

        const row = e.target.closest('.tree-view-row');
        if (!row) return;

        // Don't start drag on action buttons or toggle
        if (e.target.closest('.tree-view-action-button') ||
            e.target.closest('.tree-view-toggle'))
        {
            return;
        }

        const id = row.parentElement.dataset.id;
        const node = this.findNodeById(id);

        if (!node) return;

        this.dragState.isDragging = true;
        this.dragState.draggedNode = node;

        // Select the node
        this.selectNode(id);

        // Create drag indicator
        this.createDragIndicator();
    }

    /**
     * Handle drag move
     * @param {MouseEvent} e - Mouse event
     */
    handleDragMove(e)
    {
        if (!this.dragState.isDragging) return;

        // Find drop target
        const target = this.findDropTarget(e.clientX, e.clientY);

        if (target)
        {
            const { node, position, element } = target;

            // Check if we can drop here
            if (!this.canDrop(this.dragState.draggedNode, node, position))
            {
                this.removeDragIndicators();
                return;
            }

            this.dragState.dropTarget = node;
            this.dragState.dropPosition = position;

            // Show drop indicator
            this.showDropIndicator(element, position);
        } else
        {
            this.removeDragIndicators();
        }
    }

    /**
     * Handle drag end
     * @param {MouseEvent} e - Mouse event
     */
    handleDragEnd(e)
    {
        if (!this.dragState.isDragging) return;

        // Handle drop
        if (this.dragState.dropTarget && this.dragState.dropPosition)
        {
            this.onDrop(
                this.dragState.draggedNode,
                this.dragState.dropTarget,
                this.dragState.dropPosition
            );
        }

        // Clean up
        this.removeDragIndicators();
        this.dragState.isDragging = false;
        this.dragState.draggedNode = null;
        this.dragState.dropTarget = null;
        this.dragState.dropPosition = null;
    }

    /**
     * Create drag indicator element
     */
    createDragIndicator()
    {
        // Remove existing indicator
        this.removeDragIndicators();

        // Create new indicator
        this.dragIndicator = document.createElement('div');
        this.dragIndicator.className = 'tree-view-drop-indicator';
        document.body.appendChild(this.dragIndicator);
    }

    /**
     * Show drop indicator at the specified position
     * @param {HTMLElement} element - Target element
     * @param {string} position - Drop position ('before', 'after', 'inside')
     */
    showDropIndicator(element, position)
    {
        if (!this.dragIndicator) return;

        const rect = element.getBoundingClientRect();

        if (position === 'inside')
        {
            this.dragIndicator.classList.add('inside');
            this.dragIndicator.style.top = `${rect.top}px`;
            this.dragIndicator.style.left = `${rect.left}px`;
            this.dragIndicator.style.width = `${rect.width}px`;
            this.dragIndicator.style.height = `${rect.height}px`;
        } else
        {
            this.dragIndicator.classList.remove('inside');
            this.dragIndicator.style.top = `${position === 'before' ? rect.top - 1 : rect.bottom - 1}px`;
            this.dragIndicator.style.left = `${rect.left}px`;
            this.dragIndicator.style.width = `${rect.width}px`;
            this.dragIndicator.style.height = '2px';
        }
    }

    /**
     * Remove drag indicators
     */
    removeDragIndicators()
    {
        if (this.dragIndicator)
        {
            this.dragIndicator.remove();
            this.dragIndicator = null;
        }
    }

    /**
     * Find drop target based on mouse coordinates
     * @param {number} x - Mouse X coordinate
     * @param {number} y - Mouse Y coordinate
     * @returns {Object|null} - Drop target information
     */
    findDropTarget(x, y)
    {
        const rows = Array.from(this.container.querySelectorAll('.tree-view-row'));

        for (const row of rows)
        {
            const rect = row.getBoundingClientRect();

            if (y >= rect.top && y <= rect.bottom)
            {
                const id = row.parentElement.dataset.id;
                const node = this.findNodeById(id);

                if (!node) continue;

                // Determine drop position
                const thirdHeight = rect.height / 3;

                if (y < rect.top + thirdHeight)
                {
                    return { node, position: 'before', element: row };
                } else if (y > rect.bottom - thirdHeight)
                {
                    return { node, position: 'after', element: row };
                } else
                {
                    // Only allow dropping inside folders
                    if (node.type === 'folder')
                    {
                        return { node, position: 'inside', element: row };
                    } else
                    {
                        return { node, position: 'after', element: row };
                    }
                }
            }
        }

        return null;
    }

    /**
     * Check if a node can be dropped at the specified position
     * @param {Object} draggedNode - Node being dragged
     * @param {Object} targetNode - Target node
     * @param {string} position - Drop position
     * @returns {boolean} - Whether the drop is allowed
     */
    canDrop(draggedNode, targetNode, position)
    {
        // Can't drop on itself
        if (draggedNode.id === targetNode.id)
        {
            return false;
        }

        // Can't drop on its children
        if (this.isNodeDescendant(targetNode, draggedNode.id))
        {
            return false;
        }

        // Can only drop inside folders
        if (position === 'inside' && targetNode.type !== 'folder')
        {
            return false;
        }

        return true;
    }

    /**
     * Select a node by ID
     * @param {string|number} id - Node ID
     */
    selectNode(id)
    {
        // Deselect previously selected node
        const previouslySelected = this.container.querySelector('.tree-view-row.selected');
        if (previouslySelected)
        {
            previouslySelected.classList.remove('selected');
        }

        // Select new node
        const node = this.findNodeById(id);
        if (!node) return;

        this.selectedNode = id;

        // Update UI
        const element = this.container.querySelector(`li[data-id="${id}"] > .tree-view-row`);
        if (element)
        {
            element.classList.add('selected');
            element.scrollIntoView({ block: 'nearest' });
            element.focus();
        }

        // Trigger callback
        this.onSelect(node);
    }

    /**
     * Toggle expansion of a node
     * @param {string|number} id - Node ID
     */
    toggleNode(id)
    {
        const isExpanded = this.isNodeExpanded(id);

        if (isExpanded)
        {
            this.expandedNodes.delete(id);
        } else
        {
            this.expandedNodes.add(id);
        }

        // Update UI
        const item = this.container.querySelector(`li[data-id="${id}"]`);
        if (!item) return;

        const toggle = item.querySelector('.tree-view-toggle');
        const icon = item.querySelector('.tree-view-icon');
        const childrenContainer = item.querySelector('.tree-view-children');

        if (!childrenContainer) return;

        if (!isExpanded)
        {
            // Expand
            toggle.classList.add('expanded');

            // Update folder icon
            if (icon && icon.classList.contains('tree-view-folder-icon'))
            {
                icon.innerHTML = '📂';
            }

            // Render children if not already rendered
            const childList = childrenContainer.querySelector('.tree-view-list');
            if (childList.children.length === 0)
            {
                const node = this.findNodeById(id);
                if (node && node.children)
                {
                    this.renderNodes(node.children, childList, this.getNodeLevel(item));
                }
            }

            childrenContainer.style.display = 'block';
        } else
        {
            // Collapse
            toggle.classList.remove('expanded');

            // Update folder icon
            if (icon && icon.classList.contains('tree-view-folder-icon'))
            {
                icon.innerHTML = '📁';
            }

            childrenContainer.style.display = 'none';
        }

        // Trigger callback
        const node = this.findNodeById(id);
        if (node)
        {
            this.onToggle(node, !isExpanded);
        }
    }

    /**
     * Filter the tree based on a search string
     * @param {string} text - Filter text
     */
    filterTree(text)
    {
        if (!text || text.length === 0)
        {
            this.filteredData = null;
            this.renderTree();
            return;
        }

        // Case insensitive search
        const lowerText = text.toLowerCase();

        // Helper function to filter nodes
        const filterNode = (node) =>
        {
            const nameMatches = node.name.toLowerCase().includes(lowerText);

            // Include this node if its name matches
            if (nameMatches)
            {
                return true;
            }

            // Check children
            if (node.children && node.children.length > 0)
            {
                // Filter children recursively
                const filteredChildren = node.children.filter(filterNode);

                // Include this node if any children match
                if (filteredChildren.length > 0)
                {
                    // Clone the node with filtered children
                    return {
                        ...node,
                        children: filteredChildren
                    };
                }
            }

            return false;
        };

        // Filter the root nodes
        const filtered = this.data
            .map(node => filterNode(node))
            .filter(Boolean);

        this.filteredData = filtered;

        // Auto-expand nodes with matches
        this.expandFilteredNodes(this.filteredData);

        // Re-render the tree
        this.renderTree();
    }

    /**
     * Expand all nodes in the filtered tree
     * @param {Array} nodes - Filtered nodes to expand
     */
    expandFilteredNodes(nodes)
    {
        if (!nodes) return;

        nodes.forEach(node =>
        {
            if (node.children && node.children.length > 0)
            {
                this.expandedNodes.add(node.id);
                this.expandFilteredNodes(node.children);
            }
        });
    }

    /**
     * Select the next node in the tree
     */
    selectNextNode()
    {
        if (!this.selectedNode)
        {
            const firstNode = this.getFirstVisibleNode();
            if (firstNode)
            {
                this.selectNode(firstNode.id);
            }
            return;
        }

        const allNodes = this.getVisibleNodes();
        const currentIndex = allNodes.findIndex(node => node.id === this.selectedNode);

        if (currentIndex < allNodes.length - 1)
        {
            this.selectNode(allNodes[currentIndex + 1].id);
        }
    }

    /**
     * Select the previous node in the tree
     */
    selectPreviousNode()
    {
        if (!this.selectedNode)
        {
            const lastNode = this.getLastVisibleNode();
            if (lastNode)
            {
                this.selectNode(lastNode.id);
            }
            return;
        }

        const allNodes = this.getVisibleNodes();
        const currentIndex = allNodes.findIndex(node => node.id === this.selectedNode);

        if (currentIndex > 0)
        {
            this.selectNode(allNodes[currentIndex - 1].id);
        }
    }

    /**
     * Get all visible nodes in the tree (for keyboard navigation)
     * @returns {Array} - Flattened array of visible nodes
     */
    getVisibleNodes()
    {
        const nodes = this.filteredData || this.data;
        return this.flattenVisibleNodes(nodes);
    }

    /**
     * Flatten visible nodes recursively
     * @param {Array} nodes - Array of nodes to flatten
     * @returns {Array} - Flattened array of visible nodes
     */
    flattenVisibleNodes(nodes)
    {
        if (!nodes) return [];

        let result = [];

        nodes.forEach(node =>
        {
            result.push(node);

            if (node.children && node.children.length > 0 && this.isNodeExpanded(node.id))
            {
                result = result.concat(this.flattenVisibleNodes(node.children));
            }
        });

        return result;
    }

    /**
     * Get the first visible node in the tree
     * @returns {Object|null} - First visible node
     */
    getFirstVisibleNode()
    {
        const nodes = this.getVisibleNodes();
        return nodes.length > 0 ? nodes[0] : null;
    }

    /**
     * Get the last visible node in the tree
     * @returns {Object|null} - Last visible node
     */
    getLastVisibleNode()
    {
        const nodes = this.getVisibleNodes();
        return nodes.length > 0 ? nodes[nodes.length - 1] : null;
    }

    /**
     * Check if a node is expanded
     * @param {string|number} id - Node ID
     * @returns {boolean} - Whether the node is expanded
     */
    isNodeExpanded(id)
    {
        return this.expandedNodes.has(id);
    }

    /**
     * Find a node by its ID
     * @param {string|number} id - Node ID
     * @param {Array} [nodes] - Optional nodes array to search in
     * @returns {Object|null} - Found node or null
     */
    findNodeById(id, nodes)
    {
        nodes = nodes || this.data;

        for (const node of nodes)
        {
            if (node.id.toString() === id.toString())
            {
                return node;
            }

            if (node.children && node.children.length > 0)
            {
                const found = this.findNodeById(id, node.children);
                if (found)
                {
                    return found;
                }
            }
        }

        return null;
    }

    /**
     * Find the parent node of a given node
     * @param {string|number} id - Child node ID
     * @param {Array} [nodes] - Optional nodes array to search in
     * @param {Object} [parent] - Parent node reference
     * @returns {Object|null} - Parent node or null
     */
    findParentNode(id, nodes, parent)
    {
        nodes = nodes || this.data;

        for (const node of nodes)
        {
            if (node.children && node.children.length > 0)
            {
                if (node.children.some(child => child.id.toString() === id.toString()))
                {
                    return node;
                }

                const found = this.findParentNode(id, node.children, node);
                if (found)
                {
                    return found;
                }
            }
        }

        return null;
    }

    /**
     * Check if a node is a descendant of another node
     * @param {Object} node - Potential parent node
     * @param {string|number} id - Potential descendant ID
     * @returns {boolean} - Whether the node is a descendant
     */
    isNodeDescendant(node, id)
    {
        if (!node.children)
        {
            return false;
        }

        for (const child of node.children)
        {
            if (child.id.toString() === id.toString())
            {
                return true;
            }

            if (this.isNodeDescendant(child, id))
            {
                return true;
            }
        }

        return false;
    }

    /**
     * Get the depth level of a node in the DOM
     * @param {HTMLElement} element - Node DOM element
     * @returns {number} - Depth level
     */
    getNodeLevel(element)
    {
        let level = 0;
        let parent = element.parentElement;

        while (parent)
        {
            if (parent.classList.contains('tree-view-list') &&
                parent.parentElement.classList.contains('tree-view-children'))
            {
                level++;
            }
            parent = parent.parentElement;
        }

        return level;
    }

    /**
     * Get icon for a node
     * @param {Object} node - Tree node
     * @returns {string} - Icon HTML
     */
    getIconForNode(node)
    {
        // Check custom icons first
        if (this.icons[node.type])
        {
            return this.icons[node.type];
        }

        // Default icons
        if (node.type === 'folder')
        {
            return this.isNodeExpanded(node.id) ? '📂' : '📁';
        }

        // Default file icon
        return '📄';
    }

    /**
     * Highlight text matches in a string
     * @param {string} text - Original text
     * @param {string} highlight - Text to highlight
     * @returns {string} - HTML with highlighted text
     */
    highlightText(text, highlight)
    {
        if (!highlight) return text;

        const lowerText = text.toLowerCase();
        const lowerHighlight = highlight.toLowerCase();

        const index = lowerText.indexOf(lowerHighlight);
        if (index === -1) return text;

        const beforeMatch = text.substring(0, index);
        const match = text.substring(index, index + highlight.length);
        const afterMatch = text.substring(index + highlight.length);

        return `${beforeMatch}<span class="tree-view-highlight">${match}</span>${afterMatch}`;
    }

    /**
     * Update the tree with new data
     * @param {Array} data - New tree data
     */
    updateData(data)
    {
        this.data = data;
        this.filterTree(this.filterText);
    }

    /**
     * Expand all nodes
     */
    expandAll()
    {
        this.expandNodesRecursive(this.data);
        this.renderTree();
    }

    /**
     * Expand nodes recursively
     * @param {Array} nodes - Nodes to expand
     */
    expandNodesRecursive(nodes)
    {
        if (!nodes) return;

        nodes.forEach(node =>
        {
            if (node.children && node.children.length > 0)
            {
                this.expandedNodes.add(node.id);
                this.expandNodesRecursive(node.children);
            }
        });
    }

    /**
     * Collapse all nodes
     */
    collapseAll()
    {
        this.expandedNodes.clear();
        this.renderTree();
    }

    /**
     * Get the currently selected node
     * @returns {Object|null} - Selected node
     */
    getSelectedNode()
    {
        return this.findNodeById(this.selectedNode);
    }

    /**
     * Get all expanded node IDs
     * @returns {Array} - Array of expanded node IDs
     */
    getExpandedNodeIds()
    {
        return Array.from(this.expandedNodes);
    }

    /**
     * Set expanded nodes
     * @param {Array} ids - Array of node IDs to expand
     */
    setExpandedNodeIds(ids)
    {
        this.expandedNodes = new Set(ids);
        this.renderTree();
    }

    /**
     * Destroy the tree view component and remove event listeners
     */
    destroy()
    {
        // Remove event listeners
        this.container.removeEventListener('click', this.handleClick);
        this.container.removeEventListener('contextmenu', this.handleContextMenu);
        this.container.removeEventListener('keydown', this.handleKeyDown);

        if (this.dragEnabled)
        {
            this.container.removeEventListener('mousedown', this.handleDragStart);
            document.removeEventListener('mousemove', this.handleDragMove);
            document.removeEventListener('mouseup', this.handleDragEnd);
        }

        // Remove DOM elements
        this.container.innerHTML = '';
        this.container.classList.remove('tree-view');

        // Clean up references
        this.data = null;
        this.selectedNode = null;
        this.treeContainer = null;
        this.dragIndicator = null;
    }
}

// Export the TreeView class
if (typeof module !== 'undefined' && module.exports)
{
    module.exports = { TreeView };
} else
{
    window.TreeView = TreeView;
} 
