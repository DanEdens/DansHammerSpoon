#!/bin/bash
# Start the Custom Layouts API server

# Ensure we're in the correct directory
cd "$(dirname "$0")"

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed. Please install Python 3 and try again."
    exit 1
fi

# Check for pip
if ! command -v pip3 &> /dev/null; then
    echo "pip3 is required but not installed. Please install pip3 and try again."
    exit 1
fi

# Check for MongoDB
if ! pgrep -x "mongod" > /dev/null; then
    echo "MongoDB does not appear to be running. Starting MongoDB..."
    brew services start mongodb-community || {
        echo "Failed to start MongoDB. Please start it manually and try again."
        exit 1
    }
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "Installing dependencies..."
    ./venv/bin/pip install -r requirements.txt
fi

# Activate virtual environment and start server
echo "Starting Custom Layouts API server..."
source ./venv/bin/activate
python3 custom_layouts_api.py 
