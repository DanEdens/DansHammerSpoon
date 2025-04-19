#!/bin/bash
# Validation script for Hammerspoon configuration
# This script checks Lua syntax and ensures files are valid

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
  echo -e "${GREEN}[VALIDATE]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_message "Starting validation of Hammerspoon configuration..."

# Check if luacheck is available
if ! command -v luacheck &> /dev/null; then
  print_warning "luacheck not found. Basic syntax checking only."
  LUA_CHECK=false
else
  LUA_CHECK=true
fi

# Count total Lua files
TOTAL_FILES=$(find . -name "*.lua" | grep -v "/Spoons/" | wc -l)
print_message "Found $TOTAL_FILES Lua files to validate."

# Validate Lua syntax
ERRORS=0

validate_file() {
  local file=$1
  print_message "Checking $file..."
  
  # Basic Lua syntax check
  if ! lua -c "$file" &> /dev/null; then
    print_error "Syntax error in $file"
    lua -c "$file" 2>&1
    ERRORS=$((ERRORS + 1))
    return 1
  fi
  
  # Advanced check with luacheck if available
  if [ "$LUA_CHECK" = true ]; then
    if ! luacheck --no-unused-args --no-max-line-length "$file" &> /dev/null; then
      print_warning "Luacheck issues in $file:"
      luacheck --no-color --no-unused-args --no-max-line-length "$file"
      # Don't count warnings as errors
    fi
  fi
  
  return 0
}

# Find and validate all Lua files
find . -name "*.lua" | grep -v "/Spoons/" | while read -r file; do
  validate_file "$file" || true  # Continue even if file has errors
done

# Check if init.lua exists
if [ ! -f "./init.lua" ]; then
  print_error "init.lua not found. This is required for Hammerspoon."
  ERRORS=$((ERRORS + 1))
fi

# Summary
if [ $ERRORS -eq 0 ]; then
  print_message "Validation complete. All files passed!"
  exit 0
else
  print_error "Validation complete. Found $ERRORS error(s)."
  exit 1
fi 
