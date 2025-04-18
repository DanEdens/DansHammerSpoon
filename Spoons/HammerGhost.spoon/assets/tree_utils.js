/**
 * TreeUtils - Helper functions for working with hierarchical tree data
 */
class TreeUtils
{
    /**
     * Generate a unique ID for new tree nodes
     * @returns {string} Unique ID
     */
    static generateId()
    {
        return 'tree_' + Date.now() + '_' + Math.floor(Math.random() * 10000);
    }

    /**
     * Find a node by ID in a tree
     * @param {Array} tree Tree data
     * @param {string} id Node ID to find
     * @returns {Object|null} Found node or null
     */
    static findNodeById(tree, id)
    {
        if (!tree || !id) return null;

        // Search through each node in the tree
        for (let i = 0; i < tree.length; i++)
        {
            const node = tree[i];

            // Check if current node matches
            if (node.id === id)
            {
                return node;
            }

            // Check children recursively
            if (node.children && node.children.length > 0)
            {
                const result = this.findNodeById(node.children, id);
                if (result)
                {
                    return result;
                }
            }
        }

        return null;
    }

    /**
     * Find the parent node of a node with the given ID
     * @param {Array} tree Tree data
     * @param {string} id Child node ID
     * @returns {Object|null} Parent node or null
     */
    static findParentNode(tree, id)
    {
        if (!tree || !id) return null;

        // Check each node
        for (let i = 0; i < tree.length; i++)
        {
            const node = tree[i];

            // Check if any direct children match
            if (node.children && node.children.length > 0)
            {
                for (let j = 0; j < node.children.length; j++)
                {
                    if (node.children[j].id === id)
                    {
                        return node;
                    }
                }

                // Recursively check deeper levels
                const result = this.findParentNode(node.children, id);
                if (result)
                {
                    return result;
                }
            }
        }

        return null;
    }

    /**
     * Get the path from root to the node with the given ID
     * @param {Array} tree Tree data
     * @param {string} id Target node ID
     * @returns {Array} Array of node IDs from root to target (excluding target)
     */
    static getPathToNode(tree, id)
    {
        if (!tree || !id) return [];

        return this._getPathToNodeHelper(tree, id, []);
    }

    /**
     * Helper function for getPathToNode
     * @private
     */
    static _getPathToNodeHelper(tree, id, currentPath)
    {
        if (!tree) return [];

        for (let i = 0; i < tree.length; i++)
        {
            const node = tree[i];

            // Check if current node matches
            if (node.id === id)
            {
                return [...currentPath];
            }

            // Check children
            if (node.children && node.children.length > 0)
            {
                const newPath = [...currentPath, node.id];
                const result = this._getPathToNodeHelper(node.children, id, newPath);

                if (result.length > 0)
                {
                    return result;
                }
            }
        }

        return [];
    }

    /**
     * Move a node within the tree to a new location
     * @param {Array} tree Tree data
     * @param {string} sourceId Source node ID
     * @param {string} targetId Target node ID
     * @param {string} position Position: 'before', 'after', or 'inside'
     * @returns {Array} Updated tree
     */
    static moveNode(tree, sourceId, targetId, position)
    {
        if (!tree || !sourceId || !targetId || !position)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Find the source node and remove it from its current position
        const sourceNode = this.findNodeById(newTree, sourceId);
        if (!sourceNode) return newTree;

        // Find the parent of the source node
        const sourceParent = this.findParentNode(newTree, sourceId);

        // Remove the source node from its current position
        if (sourceParent)
        {
            sourceParent.children = sourceParent.children.filter(child => child.id !== sourceId);
        } else
        {
            // Source node is at the root level
            const index = newTree.findIndex(node => node.id === sourceId);
            if (index !== -1)
            {
                newTree.splice(index, 1);
            }
        }

        // Find the target node
        const targetNode = this.findNodeById(newTree, targetId);
        if (!targetNode) return newTree;

        // Find the parent of the target node
        const targetParent = this.findParentNode(newTree, targetId);

        // Insert the source node at the new position
        if (position === 'inside' && targetNode.type === 'folder')
        {
            // Make sure the children array exists
            if (!targetNode.children)
            {
                targetNode.children = [];
            }

            // Add to the beginning of the children array
            targetNode.children.unshift(sourceNode);
        } else if (position === 'before' || position === 'after')
        {
            let targetArray;
            let targetIndex;

            if (targetParent)
            {
                targetArray = targetParent.children;
                targetIndex = targetArray.findIndex(child => child.id === targetId);
            } else
            {
                targetArray = newTree;
                targetIndex = targetArray.findIndex(node => node.id === targetId);
            }

            if (targetIndex !== -1)
            {
                if (position === 'after')
                {
                    targetIndex++;
                }

                targetArray.splice(targetIndex, 0, sourceNode);
            }
        }

        return newTree;
    }

    /**
     * Add a new node to the tree
     * @param {Array} tree Tree data
     * @param {Object} newNode New node to add
     * @param {string|null} parentId Parent node ID or null for root level
     * @returns {Array} Updated tree
     */
    static addNode(tree, newNode, parentId = null)
    {
        if (!tree || !newNode)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Ensure the node has an ID
        if (!newNode.id)
        {
            newNode.id = this.generateId();
        }

        if (!parentId)
        {
            // Add to root level
            newTree.push(newNode);
        } else
        {
            // Find the parent node
            const parentNode = this.findNodeById(newTree, parentId);

            if (parentNode)
            {
                // Make sure the children array exists
                if (!parentNode.children)
                {
                    parentNode.children = [];
                }

                // Add the new node
                parentNode.children.push(newNode);
            } else
            {
                // Parent not found, add to root
                newTree.push(newNode);
            }
        }

        return newTree;
    }

    /**
     * Remove a node from the tree
     * @param {Array} tree Tree data
     * @param {string} id Node ID to remove
     * @returns {Array} Updated tree
     */
    static removeNode(tree, id)
    {
        if (!tree || !id)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Find parent or remove from root
        const parent = this.findParentNode(newTree, id);

        if (parent)
        {
            // Remove from parent's children
            parent.children = parent.children.filter(child => child.id !== id);

            // Remove empty children arrays
            if (parent.children.length === 0)
            {
                delete parent.children;
            }
        } else
        {
            // Remove from root level
            const index = newTree.findIndex(node => node.id === id);
            if (index !== -1)
            {
                newTree.splice(index, 1);
            }
        }

        return newTree;
    }

    /**
     * Update a node's properties
     * @param {Array} tree Tree data
     * @param {string} id Node ID to update
     * @param {Object} updates Properties to update
     * @returns {Array} Updated tree
     */
    static updateNode(tree, id, updates)
    {
        if (!tree || !id || !updates)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Find the node to update
        const node = this.findNodeById(newTree, id);

        if (node)
        {
            // Apply updates
            Object.assign(node, updates);
        }

        return newTree;
    }

    /**
     * Sort a tree or subtree by a property
     * @param {Array} tree Tree data
     * @param {string} property Property to sort by (e.g., 'name')
     * @param {boolean} [ascending=true] Sort direction
     * @param {boolean} [recursive=true] Whether to sort children recursively
     * @returns {Array} Sorted tree
     */
    static sortTree(tree, property, ascending = true, recursive = true)
    {
        if (!tree || !property)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Sort function
        const sortFn = (a, b) =>
        {
            // Put folders first
            if (a.type === 'folder' && b.type !== 'folder')
            {
                return -1;
            }
            if (a.type !== 'folder' && b.type === 'folder')
            {
                return 1;
            }

            // Then sort by property
            const valueA = a[property] || '';
            const valueB = b[property] || '';

            // Compare values based on their types
            if (typeof valueA === 'string' && typeof valueB === 'string')
            {
                return ascending
                    ? valueA.localeCompare(valueB)
                    : valueB.localeCompare(valueA);
            } else
            {
                return ascending
                    ? valueA - valueB
                    : valueB - valueA;
            }
        };

        // Sort this level
        newTree.sort(sortFn);

        // Recursively sort children
        if (recursive)
        {
            for (const node of newTree)
            {
                if (node.children && node.children.length > 0)
                {
                    node.children = this.sortTree(
                        node.children,
                        property,
                        ascending,
                        recursive
                    );
                }
            }
        }

        return newTree;
    }

    /**
     * Filter a tree to only include nodes matching the filter function
     * @param {Array} tree Tree data
     * @param {Function} filterFn Filter function that takes a node and returns boolean
     * @param {boolean} [keepPath=true] Whether to keep the path to matching nodes
     * @returns {Array} Filtered tree
     */
    static filterTree(tree, filterFn, keepPath = true)
    {
        if (!tree || !filterFn)
        {
            return tree;
        }

        // Clone the tree to avoid modifying the original
        const newTree = JSON.parse(JSON.stringify(tree));

        // Keep track of nodes to preserve (for path keeping)
        let nodesToKeep = new Set();

        // First pass: identify all nodes that match the filter
        // and their ancestors if keepPath is true
        const identifyNodesToKeep = (nodes, path = []) =>
        {
            let hasMatchingDescendant = false;

            for (const node of nodes)
            {
                const newPath = [...path, node.id];
                let matches = filterFn(node);
                let childrenMatch = false;

                if (node.children && node.children.length > 0)
                {
                    childrenMatch = identifyNodesToKeep(node.children, newPath);
                }

                if (matches || childrenMatch)
                {
                    hasMatchingDescendant = true;

                    if (matches)
                    {
                        nodesToKeep.add(node.id);
                    }

                    if (keepPath && (matches || childrenMatch))
                    {
                        // Add all ancestors to the keep set
                        path.forEach(id => nodesToKeep.add(id));
                    }
                }
            }

            return hasMatchingDescendant;
        };

        identifyNodesToKeep(newTree);

        // Second pass: filter out nodes that should not be kept
        const filterNodes = (nodes) =>
        {
            return nodes.filter(node =>
            {
                if (!nodesToKeep.has(node.id))
                {
                    return false;
                }

                if (node.children && node.children.length > 0)
                {
                    node.children = filterNodes(node.children);
                }

                return true;
            });
        };

        return filterNodes(newTree);
    }

    /**
     * Search a tree for nodes matching the search text
     * @param {Array} tree Tree data
     * @param {string} searchText Text to search for
     * @param {Array} [properties=['name']] Properties to search in
     * @param {boolean} [keepPath=true] Whether to keep the path to matching nodes
     * @returns {Array} Tree with only matching nodes
     */
    static searchTree(tree, searchText, properties = ['name'], keepPath = true)
    {
        if (!tree || !searchText)
        {
            return tree;
        }

        const searchLower = searchText.toLowerCase();

        const filterFn = node =>
        {
            for (const prop of properties)
            {
                if (node[prop] && String(node[prop]).toLowerCase().includes(searchLower))
                {
                    return true;
                }
            }
            return false;
        };

        return this.filterTree(tree, filterFn, keepPath);
    }

    /**
     * Expand all folders in the path to a node
     * @param {Array} tree Tree data
     * @param {string} id Target node ID
     * @returns {Object} Map of expanded node IDs
     */
    static getExpandedForNode(tree, id)
    {
        const path = this.getPathToNode(tree, id);
        const expanded = {};

        // Mark all folders in the path as expanded
        path.forEach(nodeId =>
        {
            expanded[nodeId] = true;
        });

        return expanded;
    }

    /**
     * Flatten a tree into an array
     * @param {Array} tree Tree data
     * @returns {Array} Flat array of all nodes
     */
    static flattenTree(tree)
    {
        if (!tree)
        {
            return [];
        }

        let result = [];

        for (const node of tree)
        {
            result.push(node);

            if (node.children && node.children.length > 0)
            {
                result = result.concat(this.flattenTree(node.children));
            }
        }

        return result;
    }

    /**
     * Group nodes in a flat array back into a tree structure
     * @param {Array} nodes Flat array of nodes with parent IDs
     * @param {string} [parentIdKey='parentId'] Key for the parent ID property
     * @param {any} [rootParentId=null] Value of parentId for root nodes
     * @returns {Array} Tree data
     */
    static buildTreeFromFlatArray(nodes, parentIdKey = 'parentId', rootParentId = null)
    {
        if (!nodes)
        {
            return [];
        }

        // Create a map of nodes by ID for quick lookup
        const nodeMap = {};
        for (const node of nodes)
        {
            nodeMap[node.id] = { ...node, children: [] };
        }

        // Build the tree
        const tree = [];

        for (const node of nodes)
        {
            const parentId = node[parentIdKey];
            const mappedNode = nodeMap[node.id];

            if (parentId === rootParentId)
            {
                // Root level node
                tree.push(mappedNode);
            } else if (nodeMap[parentId])
            {
                // Add as child to parent node
                nodeMap[parentId].children.push(mappedNode);
            } else
            {
                // Parent not found, add to root
                tree.push(mappedNode);
            }
        }

        return tree;
    }

    /**
     * Export a tree to JSON
     * @param {Array} tree Tree data
     * @returns {string} JSON string
     */
    static exportToJson(tree)
    {
        if (!tree)
        {
            return '[]';
        }

        return JSON.stringify(tree, null, 2);
    }

    /**
     * Import a tree from JSON
     * @param {string} json JSON string
     * @returns {Array} Tree data
     */
    static importFromJson(json)
    {
        if (!json)
        {
            return [];
        }

        try
        {
            return JSON.parse(json);
        } catch (e)
        {
            console.error('Failed to parse tree JSON:', e);
            return [];
        }
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports)
{
    module.exports = { TreeUtils };
} 
