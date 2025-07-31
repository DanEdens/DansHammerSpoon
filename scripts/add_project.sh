#!/bin/bash

# Default values
PROJECT_PATH=""
DESCRIPTION=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --project-path) PROJECT_PATH="$2"; shift ;;
        --desc) DESCRIPTION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if project path is provided
if [ -z "$PROJECT_PATH" ]; then
    echo "Error: --project-path is required."
    exit 1
fi

# Set default description if not provided
if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="Imported from script"
fi

# Expand path to be absolute using Python
PROJECT_PATH=$(python -c "import os; print(os.path.abspath(os.path.expanduser('$PROJECT_PATH')))")

# JSON file path
JSON_FILE="data/projects.json"
if [ ! -f "$JSON_FILE" ]; then
    echo "{\"projects\":[]}" > "$JSON_FILE"
fi

# Generate new project data
if command -v uuidgen &> /dev/null; then
    ID=$(uuidgen)
else
    # basic uuidgen fallback for systems that don't have it
    ID=$(python -c 'import uuid; print(str(uuid.uuid4()).upper())')
fi
TIMESTAMP=$(date +%s)
PROJECT_NAME=$(basename "$PROJECT_PATH")

# Use jq to add the new project
jq --arg path "$PROJECT_PATH" \
   --arg id "$ID" \
   --arg name "$PROJECT_NAME" \
   --arg desc "$DESCRIPTION" \
   --argjson ts "$TIMESTAMP" \
   '.projects += [{path: $path, lastModified: $ts, created: $ts, id: $id, name: $name, description: $desc}]' \
   "$JSON_FILE" > "$JSON_FILE.tmp"

# Check if jq succeeded
if [ $? -eq 0 ]; then
    mv "$JSON_FILE.tmp" "$JSON_FILE"
    # Make it pretty
    jq '.' "$JSON_FILE" > "$JSON_FILE.tmp" && mv "$JSON_FILE.tmp" "$JSON_FILE"
    echo "Project '$PROJECT_NAME' added to $JSON_FILE"
else
    rm "$JSON_FILE.tmp"
    echo "Error: Failed to update $JSON_FILE with jq."
    exit 1
fi 
