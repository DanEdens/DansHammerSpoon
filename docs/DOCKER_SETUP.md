# Hammerspoon Configuration Docker Setup

This document provides detailed instructions for using the Docker setup for development, testing, and deployment of the Hammerspoon configuration.

## Overview

The Docker setup consists of two main components:

1. **Development Environment**: A Docker container for validating, testing, and developing the Hammerspoon configuration without affecting your local system.
2. **Deployment Script**: A macOS-specific script to install Hammerspoon and deploy the configuration to a real macOS system.

## Development Environment

The development environment is based on Alpine Linux and includes:

- Lua 5.3 runtime
- LuaRocks package manager
- Luacheck for code linting
- Git for version control
- Additional development tools

### Building the Development Image

To build the development Docker image:

```bash
cd /path/to/repository
docker build -t hammerspoon-dev -f docker/dev/Dockerfile .
```

### Using Docker Compose

For convenience, a Docker Compose file is provided:

```bash
cd /path/to/repository/docker/dev
docker-compose up -d
docker-compose exec hammerspoon-dev bash
```

This will start the container and give you a shell inside it with the repository mounted.

### Validating the Configuration

Inside the development container, you can validate the Lua configuration:

```bash
./validate.sh
```

This script will:
- Check basic Lua syntax
- Run luacheck (if available)
- Ensure required files are present

## Deploying to macOS

Since Hammerspoon is a macOS-specific application, deployment needs to happen on an actual macOS system.

### Prerequisites

- macOS 10.12+
- Administrative privileges (for Homebrew installation)
- Internet connection (for downloading Hammerspoon)

### Installation Steps

1. Clone the repository on your macOS system:

```bash
git clone https://github.com/yourusername/hammerspoon-config.git
cd hammerspoon-config
```

2. Run the installation script:

```bash
./docker/deploy/install_macos.sh
```

This script will:
- Install Homebrew (if not already installed)
- Install Hammerspoon via Homebrew
- Back up any existing Hammerspoon configuration
- Copy the configuration files to `~/.hammerspoon/`
- Start or reload Hammerspoon

### After Installation

After installation, Hammerspoon will be running with the new configuration. You can access the ProjectManager using `Cmd+Ctrl+Alt+J`.

## Continuous Integration

The Docker setup can be used in CI/CD pipelines to validate your configuration on each commit or pull request.

### GitHub Actions

A GitHub Actions workflow is included in `.github/workflows/validate.yml`. This workflow builds the Docker development image and runs the validation script on each push to main and on pull requests.

### Custom CI Integration

For custom CI systems, you can use the same approach:

1. Build the Docker image
2. Run the container with the validation script

Example:

```bash
docker build -t hammerspoon-dev -f docker/dev/Dockerfile .
docker run hammerspoon-dev ./validate.sh
```

## Limitations and Notes

- Docker cannot run actual macOS containers due to licensing restrictions
- The development environment is for code validation and testing only
- UI testing requires a real macOS system
- The Docker setup doesn't include Hammerspoon itself, only the configuration files
- For true Hammerspoon functionality, deploy to a real macOS system using the install script

## Troubleshooting

### Development Environment Issues

- **Missing dependencies**: Modify the Dockerfile to add required packages
- **Permissions issues**: Run `chmod +x` on scripts if they aren't executable

### Deployment Issues

- **Homebrew installation fails**: Try installing Homebrew manually following instructions at brew.sh
- **Hammerspoon won't start**: Check Console.app for error messages
- **Configuration not loading**: Verify files were copied to `~/.hammerspoon/` 
