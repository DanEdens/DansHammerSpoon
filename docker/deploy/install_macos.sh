#!/bin/bash
# Hammerspoon Configuration Installation Script for macOS
# This script installs Hammerspoon and sets up the configuration

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
  echo -e "${GREEN}[HAMMERSPOON-INSTALL]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  print_error "This script is for macOS only. Exiting."
  exit 1
fi

# Change to the script's directory
cd "$(dirname "$0")"
cd ../..  # Go up to the project root

print_message "Starting Hammerspoon installation..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  print_message "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  print_message "Homebrew is already installed."
fi

# Install Hammerspoon if not already installed
if ! brew list --cask hammerspoon &> /dev/null; then
  print_message "Installing Hammerspoon..."
  brew install --cask hammerspoon
else
  print_message "Hammerspoon is already installed. Checking for updates..."
  brew upgrade --cask hammerspoon
fi

# Create .hammerspoon directory if it doesn't exist
HAMMERSPOON_DIR="$HOME/.hammerspoon"
if [ ! -d "$HAMMERSPOON_DIR" ]; then
  print_message "Creating .hammerspoon directory..."
  mkdir -p "$HAMMERSPOON_DIR"
else
  print_message ".hammerspoon directory already exists."
fi

# Backup existing configuration if present
if [ -f "$HAMMERSPOON_DIR/init.lua" ]; then
  BACKUP_DIR="$HAMMERSPOON_DIR/backup_$(date +%Y%m%d%H%M%S)"
  print_warning "Existing Hammerspoon configuration found. Backing up to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  cp -R "$HAMMERSPOON_DIR"/* "$BACKUP_DIR/"
fi

# Copy configuration files
print_message "Copying configuration files..."
cp -R ./*.lua "$HAMMERSPOON_DIR/"
cp -R ./*.md "$HAMMERSPOON_DIR/"

# Create required directories
print_message "Creating required directories..."
mkdir -p "$HAMMERSPOON_DIR/logs"

# Special handling for projects.json to prevent overwriting existing projects
if [ -f "$HAMMERSPOON_DIR/projects.json" ]; then
  print_warning "Existing projects.json found. Not overwriting."
else
  print_message "Creating empty projects.json"
  echo '{"projects":[]}' > "$HAMMERSPOON_DIR/projects.json"
fi

# Make scripts executable
if [ -d "$HAMMERSPOON_DIR/scripts" ]; then
  print_message "Making scripts executable..."
  find "$HAMMERSPOON_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
fi

# Check if Hammerspoon is running
if pgrep -x "Hammerspoon" > /dev/null; then
  print_message "Reloading Hammerspoon..."
  osascript -e 'tell application "Hammerspoon" to reload config'
else
  print_message "Starting Hammerspoon..."
  open -a Hammerspoon
fi

print_message "Installation complete! Hammerspoon is now configured and running."
print_message "Press Cmd+Ctrl+Alt+J to open the Project Manager." 
