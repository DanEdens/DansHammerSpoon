// HammerGhost - Main Application JavaScript
document.addEventListener('DOMContentLoaded', function ()
{
    // Core application state
    const appState = {
        currentView: 'welcome',
        selectedNode: null,
        isDarkMode: window.matchMedia('(prefers-color-scheme: dark)').matches,
        settings: loadSettings(),
        keyboardShortcuts: {
            'Escape': closeActiveModal,
            'F1': showHelp,
            'F5': refreshTreeView,
            'n': handleNewItemShortcut,
            's': () => { if (isModifierKeyPressed('ctrlKey')) { saveCurrentState(); } },
            'f': () => { if (isModifierKeyPressed('ctrlKey')) { focusSearch(); } },
            '/': focusSearch
        }
    };

    // Initialize UI components
    initializeUI();
    setupEventListeners();

    // Load tree data if available
    if (window.hammerspoon && window.hammerspoon.getTreeData)
    {
        refreshTreeView();
    } else
    {
        console.warn('Hammerspoon bridge not available - running in dev mode');
        loadDevModeData();
    }

    // Core functions
    function initializeUI()
    {
        // Ensure all modals are hidden on load
        document.querySelectorAll('.modal').forEach(modal =>
        {
            modal.classList.add('hidden');
        });

        // Make sure the modal container is hidden too
        const modalContainer = document.getElementById('modalContainer');
        if (modalContainer)
        {
            modalContainer.classList.add('hidden');
        }

        // Set up close buttons for modals
        document.querySelectorAll('[data-close-modal]').forEach(button =>
        {
            button.addEventListener('click', () =>
            {
                // Find the closest modal parent
                const modal = button.closest('.modal');
                if (modal)
                {
                    modal.classList.add('hidden');
                    document.getElementById('modalContainer').classList.add('hidden');
                }
            });
        });

        updateTheme();
        showView(appState.currentView);
        updateSettingsUI();
        addKeyboardShortcutHints();
    }

    function setupEventListeners()
    {
        // Navigation buttons
        document.querySelectorAll('[data-view]').forEach(button =>
        {
            button.addEventListener('click', function ()
            {
                showView(this.dataset.view);
            });
        });

        // Action buttons
        document.getElementById('refreshTree')?.addEventListener('click', refreshTreeView);
        document.getElementById('newFolder')?.addEventListener('click', showNewFolderModal);
        document.getElementById('settingsBtn')?.addEventListener('click', showSettingsModal);
        document.getElementById('saveSettings')?.addEventListener('click', saveSettingsFromUI);

        // Welcome screen buttons
        document.getElementById('welcomeNewFolder')?.addEventListener('click', showNewFolderModal);
        document.getElementById('welcomeNewAction')?.addEventListener('click', () => showActionModal('new'));

        // Form submissions
        document.getElementById('newFolderForm')?.addEventListener('submit', createNewFolder);

        // Theme toggle
        document.getElementById('themeToggle')?.addEventListener('click', toggleTheme);

        // Global keyboard shortcuts
        document.addEventListener('keydown', handleKeyboardShortcuts);
    }

    function handleKeyboardShortcuts(event)
    {
        // Don't capture keyboard shortcuts when user is typing in an input
        if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA')
        {
            return;
        }

        const key = event.key;
        const shortcutFn = appState.keyboardShortcuts[key];

        if (shortcutFn)
        {
            event.preventDefault();
            shortcutFn(event);
        }
    }

    function isModifierKeyPressed(modifier)
    {
        return event[modifier] === true;
    }

    function handleNewItemShortcut(event)
    {
        if (isModifierKeyPressed('shiftKey'))
        {
            showNewFolderModal();
        } else
        {
            showActionModal('new');
        }
    }

    function closeActiveModal()
    {
        const visibleModal = document.querySelector('.modal:not(.hidden)');
        if (visibleModal)
        {
            closeModal(visibleModal.id);
            return true;
        }
        return false;
    }

    function focusSearch()
    {
        const searchInput = document.querySelector('.tree-view-filter-input');
        if (searchInput)
        {
            searchInput.focus();
        }
    }

    function saveCurrentState()
    {
        // Implement saving current state to Hammerspoon
        if (window.hammerspoon && window.hammerspoon.saveState)
        {
            window.hammerspoon.saveState();
            showSuccess('Changes saved');
        }
    }

    function showHelp()
    {
        // Show keyboard shortcuts help
        const helpContent = `
            <h3>Keyboard Shortcuts</h3>
            <ul>
                <li><kbd>Esc</kbd> - Close active modal</li>
                <li><kbd>F1</kbd> - Show this help</li>
                <li><kbd>F5</kbd> - Refresh tree view</li>
                <li><kbd>N</kbd> - New action</li>
                <li><kbd>Shift</kbd> + <kbd>N</kbd> - New folder</li>
                <li><kbd>Ctrl</kbd> + <kbd>S</kbd> - Save changes</li>
                <li><kbd>Ctrl</kbd> + <kbd>F</kbd> or <kbd>/</kbd> - Focus search</li>
            </ul>
        `;

        showModal('Keyboard Shortcuts', helpContent);
    }

    function showModal(title, content)
    {
        // Create a generic modal for displaying information
        const modalContainer = document.getElementById('modalContainer');
        if (!modalContainer) return;

        const modalId = 'genericModal';
        let modal = document.getElementById(modalId);

        if (!modal)
        {
            modal = document.createElement('div');
            modal.id = modalId;
            modal.className = 'modal';
            modal.innerHTML = `
                <div class="modal-header">
                    <h3 id="genericModalTitle"></h3>
                    <button class="close-button" data-close-modal>&times;</button>
                </div>
                <div class="modal-body" id="genericModalContent"></div>
                <div class="modal-footer">
                    <button class="btn primary" data-close-modal>Close</button>
                </div>
            `;
            modalContainer.appendChild(modal);

            modal.querySelector('[data-close-modal]').addEventListener('click', () =>
            {
                closeModal(modalId);
            });
        }

        document.getElementById('genericModalTitle').textContent = title;
        document.getElementById('genericModalContent').innerHTML = content;

        modalContainer.classList.remove('hidden');
        modal.classList.remove('hidden');
    }

    function showView(viewName)
    {
        // Hide all views
        document.querySelectorAll('.view-content').forEach(view =>
        {
            view.style.display = 'none';
        });

        // Show requested view
        const viewElement = document.getElementById(viewName + 'View');
        if (viewElement)
        {
            viewElement.style.display = 'block';
            appState.currentView = viewName;
        }
    }

    function refreshTreeView()
    {
        try
        {
            if (window.hammerspoon && window.hammerspoon.getTreeData)
            {
                const treeData = JSON.parse(window.hammerspoon.getTreeData());
                initializeTree(treeData);
                showView('tree');
            }
        } catch (error)
        {
            showError('Failed to load tree data: ' + error.message);
        }
    }

    function showNewFolderModal()
    {
        const modal = document.getElementById('newFolderModal');
        if (!modal) return;

        modal.style.display = 'flex';
        document.getElementById('folderName')?.focus();
    }

    function showActionModal(type)
    {
        // Logic for showing action modal (new/edit)
        // This would be implemented when we have an action editor
        showNotification('Action editor coming soon', 'info');
    }

    function showSettingsModal()
    {
        const modal = document.getElementById('settingsModal');
        if (!modal) return;

        modal.style.display = 'flex';
    }

    function createNewFolder(event)
    {
        event.preventDefault();
        const folderNameInput = document.getElementById('folderName');
        if (!folderNameInput) return;

        const folderName = folderNameInput.value.trim();

        if (folderName)
        {
            if (window.hammerspoon && window.hammerspoon.createFolder)
            {
                try
                {
                    const result = window.hammerspoon.createFolder(folderName, appState.selectedNode?.id || 'root');
                    if (result)
                    {
                        document.getElementById('newFolderModal').style.display = 'none';
                        folderNameInput.value = '';
                        refreshTreeView();
                        showSuccess('Folder created successfully');
                    }
                } catch (error)
                {
                    showError('Failed to create folder: ' + error.message);
                }
            }
        }
    }

    function closeModal(modalId)
    {
        const modal = document.getElementById(modalId);
        if (modal)
        {
            modal.style.display = 'none';
            // If this is the last visible modal, hide the container too
            const visibleModals = document.querySelectorAll('#modalContainer .modal:not([style*="display: none"])');
            if (visibleModals.length === 0)
            {
                document.getElementById('modalContainer')?.classList.add('hidden');
            }
        }
    }

    // Close modals when clicking outside or on close button
    document.querySelectorAll('.modal-bg').forEach(modal =>
    {
        modal.addEventListener('click', function (event)
        {
            if (event.target === this)
            {
                this.style.display = 'none';
            }
        });
    });

    document.querySelectorAll('.close-modal').forEach(button =>
    {
        button.addEventListener('click', function ()
        {
            const modal = this.closest('.modal-bg');
            if (modal)
            {
                modal.style.display = 'none';
            }
        });
    });

    // Settings management
    function loadSettings()
    {
        const defaultSettings = {
            autoExpandNodes: true,
            showHiddenFiles: false,
            searchDelay: 300,
            theme: 'system'
        };

        try
        {
            if (window.hammerspoon && window.hammerspoon.getSettings)
            {
                return JSON.parse(window.hammerspoon.getSettings()) || defaultSettings;
            }
            const storedSettings = localStorage.getItem('hammerGhostSettings');
            return storedSettings ? JSON.parse(storedSettings) : defaultSettings;
        } catch (error)
        {
            console.error('Error loading settings:', error);
            return defaultSettings;
        }
    }

    function saveSettings(settings)
    {
        appState.settings = settings;

        if (window.hammerspoon && window.hammerspoon.saveSettings)
        {
            window.hammerspoon.saveSettings(JSON.stringify(settings));
        } else
        {
            localStorage.setItem('hammerGhostSettings', JSON.stringify(settings));
        }

        updateTheme();
    }

    function updateSettingsUI()
    {
        const autoExpandEl = document.getElementById('autoExpandNodes');
        const hiddenFilesEl = document.getElementById('showHiddenFiles');
        const searchDelayEl = document.getElementById('searchDelay');
        const themeEl = document.getElementById('themeSelect');

        if (autoExpandEl) autoExpandEl.checked = appState.settings.autoExpandNodes;
        if (hiddenFilesEl) hiddenFilesEl.checked = appState.settings.showHiddenFiles;
        if (searchDelayEl) searchDelayEl.value = appState.settings.searchDelay;
        if (themeEl) themeEl.value = appState.settings.theme;
    }

    function saveSettingsFromUI()
    {
        const settings = {
            autoExpandNodes: document.getElementById('autoExpandNodes')?.checked || false,
            showHiddenFiles: document.getElementById('showHiddenFiles')?.checked || false,
            searchDelay: parseInt(document.getElementById('searchDelay')?.value || '300', 10),
            theme: document.getElementById('themeSelect')?.value || 'system'
        };

        saveSettings(settings);
        closeModal('settingsModal');
        showSuccess('Settings saved');

        // Apply settings changes immediately
        refreshTreeView();
    }

    // Theme management
    function updateTheme()
    {
        const { theme } = appState.settings;
        const isDark = theme === 'dark' ||
            (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

        appState.isDarkMode = isDark;
        document.body.classList.toggle('dark-theme', isDark);
        document.body.classList.toggle('light-theme', !isDark);

        if (window.hammerspoon && window.hammerspoon.setTheme)
        {
            window.hammerspoon.setTheme(isDark ? 'dark' : 'light');
        }

        updateThemeToggleIcon();
    }

    function toggleTheme()
    {
        const currentTheme = appState.settings.theme;
        let newTheme;

        if (currentTheme === 'system')
        {
            newTheme = appState.isDarkMode ? 'light' : 'dark';
        } else
        {
            newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        }

        const settings = { ...appState.settings, theme: newTheme };
        saveSettings(settings);
    }

    function updateThemeToggleIcon()
    {
        const icon = document.getElementById('themeToggleIcon');
        if (icon)
        {
            icon.className = appState.isDarkMode ? 'fas fa-sun' : 'fas fa-moon';
        }
    }

    // Add keyboard shortcut hints to UI elements
    function addKeyboardShortcutHints()
    {
        // Add keyboard shortcut hints next to buttons
        const shortcuts = {
            'newFolder': 'Shift+N',
            'newAction': 'N',
            'refreshTree': 'F5',
            'saveBtn': 'Ctrl+S',
            'settingsBtn': '⚙'
        };

        Object.entries(shortcuts).forEach(([id, key]) =>
        {
            const element = document.getElementById(id);
            if (element)
            {
                const hintEl = document.createElement('span');
                hintEl.className = 'kb-hint';
                hintEl.textContent = key;
                element.appendChild(hintEl);
            }
        });
    }

    // Notification system
    function showNotification(message, type)
    {
        // Create notification element if it doesn't exist
        let notificationArea = document.getElementById('notificationArea');
        if (!notificationArea)
        {
            notificationArea = document.createElement('div');
            notificationArea.id = 'notificationArea';
            notificationArea.className = 'notification-area';
            document.body.appendChild(notificationArea);
        }

        const notification = document.createElement('div');
        notification.className = `notification ${type || 'info'}`;
        notification.textContent = message;

        // Add close button
        const closeBtn = document.createElement('button');
        closeBtn.className = 'notification-close';
        closeBtn.innerHTML = '&times;';
        closeBtn.addEventListener('click', () =>
        {
            notification.classList.add('fade-out');
            setTimeout(() => notification.remove(), 300);
        });
        notification.appendChild(closeBtn);

        notificationArea.appendChild(notification);

        // Auto-dismiss after a delay
        setTimeout(() =>
        {
            notification.classList.add('fade-out');
            setTimeout(() => notification.remove(), 300);
        }, 5000);
    }

    function showSuccess(message)
    {
        showNotification(message, 'success');
    }

    function showError(message)
    {
        showNotification(message, 'error');
    }

    function loadDevModeData()
    {
        const demoData = {
            id: 'root',
            name: 'Home',
            type: 'folder',
            expanded: true,
            children: [
                {
                    id: 'folder1',
                    name: 'Applications',
                    type: 'folder',
                    expanded: false,
                    children: [
                        { id: 'app1', name: 'Calculator.app', type: 'file' },
                        { id: 'app2', name: 'Calendar.app', type: 'file' },
                        { id: 'app3', name: 'Mail.app', type: 'file' }
                    ]
                },
                {
                    id: 'folder2',
                    name: 'Documents',
                    type: 'folder',
                    expanded: true,
                    children: [
                        { id: 'doc1', name: 'Report.pdf', type: 'file' },
                        { id: 'doc2', name: 'Budget.xlsx', type: 'file' },
                        {
                            id: 'subfolder1',
                            name: 'Projects',
                            type: 'folder',
                            expanded: false,
                            children: [
                                { id: 'proj1', name: 'Project A', type: 'file' },
                                { id: 'proj2', name: 'Project B', type: 'file' }
                            ]
                        }
                    ]
                },
                {
                    id: 'folder3',
                    name: 'Scripts',
                    type: 'folder',
                    expanded: false,
                    children: [
                        { id: 'script1', name: 'init.lua', type: 'file' },
                        { id: 'script2', name: 'config.lua', type: 'file' }
                    ]
                }
            ]
        };

        initializeTree(demoData);
        document.body.classList.add('dev-mode');
        showNotification('Running in development mode', 'info');
    }

    // Initialize the tree view with the demo data
    function initializeTree(data)
    {
        const treeElement = document.getElementById('treeView');
        if (!treeElement) return;

        // Here we would initialize our tree view component
        // For now, just log that we received data
        console.log('Initializing tree with data:', data);

        // If the tree_view.js script is properly loaded, it should have a global
        // TreeView constructor we can use
        if (typeof TreeView === 'function')
        {
            const treeView = new TreeView({
                container: treeElement,
                data: data,
                dragEnabled: true,
                searchEnabled: true,
                keyboardNavigation: true,
                onSelect: function (node)
                {
                    appState.selectedNode = node;
                    console.log('Selected node:', node);
                },
                onDrop: function (draggedId, targetId, position)
                {
                    console.log('Dropped', draggedId, 'onto', targetId, 'at', position);
                    // Send to Hammerspoon via hammerspoon://moveItem?...
                    if (window.hammerspoon && window.hammerspoon.moveItem)
                    {
                        window.hammerspoon.moveItem(JSON.stringify({
                            sourceId: draggedId,
                            targetId: targetId,
                            position: position
                        }));
                    }
                }
            });
        } else
        {
            treeElement.innerHTML = '<div class="tree-error">Tree view component not loaded!</div>';
        }
    }

    // Expose public methods to enable Hammerspoon communication
    window.appInterface = {
        refreshTree: refreshTreeView,
        showSuccess,
        showError,
        showNotification,
        setSelectedNode: (nodeId) =>
        {
            appState.selectedNode = { id: nodeId };
        }
    };

    // Define App namespace for initializers
    window.App = {
        init: function ()
        {
            console.log('App initialized');
        }
    };
});
