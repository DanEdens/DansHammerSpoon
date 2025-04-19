# Docker Setup for Hammerspoon Configuration

This directory contains Docker configurations for developing and deploying the Hammerspoon configuration.

## Structure

- `dev/`: Development environment for working with the Hammerspoon configuration files
- `deploy/`: Deployment scripts for installing Hammerspoon configuration on macOS systems

## Development Environment

The development environment is useful for:
- Validating Lua syntax
- Making and testing changes in a consistent environment
- Running tests without affecting your local Hammerspoon installation

### Usage

Navigate to the `docker/dev` directory and run:

```bash
docker-compose up -d
docker-compose exec hammerspoon-dev bash
```

This will start the development container and give you a shell inside it.

Inside the container, you can:
- Run `./validate.sh` to check Lua syntax
- Edit configuration files (changes will be reflected on your host system)
- Use Git to manage changes

## macOS Deployment

Since Hammerspoon is macOS-specific, actual deployment needs to happen on a macOS system.

### Installing on macOS

1. Clone this repository on your macOS system:

```bash
git clone <repository-url>
cd hammerspoon-config
```

2. Run the installation script:

```bash
./docker/deploy/install_macos.sh
```

This will:
- Install Hammerspoon via Homebrew (if not already installed)
- Backup any existing Hammerspoon configuration
- Copy the configuration files to ~/.hammerspoon/
- Start/reload Hammerspoon

## Notes on Docker and macOS

Docker cannot run actual macOS containers due to licensing restrictions. The Docker setup provided here is primarily for development and testing purposes. For actual deployment, use the installation script on a real macOS system.

## Continuous Integration

The development Docker image can be used in CI/CD pipelines to:
- Validate syntax
- Run tests
- Ensure code quality

Example GitLab CI configuration:

```yaml
stages:
  - validate

validate:
  stage: validate
  image: ${CI_REGISTRY_IMAGE}/hammerspoon-dev:latest
  script:
    - ./validate.sh
``` 
