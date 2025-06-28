#!/bin/bash

# Function to navigate to git hooks directory
# Usage: hooks
# This will pushd to the hooks directory of the current git repository
hooks() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    # Get the git directory (handles both .git folder and .git file cases)
    local git_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    
    if [ -z "$git_dir" ]; then
        echo "❌ Could not determine git directory"
        return 1
    fi
    
    # Convert to absolute path if it's relative
    if [[ ! "$git_dir" = /* ]]; then
        git_dir="$(pwd)/$git_dir"
    fi
    
    # Construct hooks directory path
    local hooks_dir="$git_dir/hooks"
    
    # Check if hooks directory exists
    if [ ! -d "$hooks_dir" ]; then
        echo "❌ Hooks directory does not exist: $hooks_dir"
        return 1
    fi
    
    # Use pushd to navigate to hooks directory
    echo "🔧 Navigating to git hooks: $hooks_dir"
    pushd "$hooks_dir" || return 1
    
    # List hooks if any exist
    if ls -la | grep -q "^-.*\(pre-\|post-\|prepare-\)"; then
        echo "📋 Current git hooks:"
        ls -la | grep "^-.*\(pre-\|post-\|prepare-\|update\|applypatch\|commit-msg\|rebase\)" | while read -r line; do
            echo "  $line"
        done
    else
        echo "📝 No git hooks found in this directory"
    fi
}

# Export the function so it's available when sourced
export -f hooks 
