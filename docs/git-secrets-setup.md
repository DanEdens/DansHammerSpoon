# Git Secrets Setup

This repository uses [git-secrets](https://github.com/awslabs/git-secrets) to prevent committing sensitive information like API keys, passwords, tokens, or private keys.

## How It Works

Git-secrets scans commits, commit messages, and `--no-ff` merges to prevent adding secrets into your git repositories. If a commit, commit message, or any commit in a `--no-ff` merge contains a secret pattern, the commit will be rejected.

## Setup

The repository is already configured with git-secrets hooks. If you're setting up a new clone, run:

```bash
# Install git-secrets (macOS)
brew install git-secrets

# Set up git-secrets in the repository
cd ~/.hammerspoon
git secrets --install
git secrets --register-aws

# Register additional patterns
git secrets --add 'private_key|private key|privatekey'
git secrets --add 'api[_]?key|api[_]?secret|token|secret|password'

# Add allowed patterns (for examples/placeholders)
git secrets --add --allowed 'EXAMPLE_API_KEY|PLACEHOLDER|YOUR_KEY_HERE'
```

## Using Secrets in This Project

1. Copy `.secrets.example` to `.secrets`:
   ```bash
   cp .secrets.example .secrets
   ```

2. Edit `.secrets` and add your actual secret values:
   ```bash
   EXAMPLE_API_KEY="your-actual-api-key-here"
   MCP_SERVER_API_KEY="your-actual-mcp-server-key"
   ```

3. In your Lua code, load the secrets using:
   ```lua
   local secrets = require("load_secrets")
   
   -- Use a secret
   local apiKey = secrets.EXAMPLE_API_KEY
   
   -- Use a secret with a fallback value
   local debugMode = secrets.get("DEBUG_MODE", false)
   ```

4. The `.secrets` file is in `.gitignore` and will not be committed.

## Testing the Hooks

To verify that git-secrets is working:

```bash
# Test with a fake AWS key (should fail)
echo "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > test_file.txt
git add test_file.txt
git commit -m "test commit"
# Should prevent the commit

# Clean up
rm test_file.txt
```

## Scanning the Repository

To scan the entire repository for secrets:

```bash
git secrets --scan
```

To scan specific files:

```bash
git secrets --scan /path/to/file
``` 
