# AI Tools Secret Management

This document covers the secure storage and management of API keys for AI tools in your nix-config.

## Overview

The nix-config uses **macOS Keychain** to securely store AI API keys. This provides:

- ✅ **Secure storage** using macOS's built-in encryption
- ✅ **Touch ID integration** for secure access
- ✅ **Automatic environment variable sourcing** in shell sessions
- ✅ **No additional packages** required (uses built-in `security` command)
- ✅ **Simple CLI tools** for key management

## Quick Start

### 1. Enable Secret Management

Add to your `home/jrudnik/home.nix`:

```nix
programs.ai.secrets = {
  enable = true;
  shellIntegration = true;  # Automatically source secrets
};
```

### 2. Add API Keys

```bash
# Add your API keys to keychain
ai-add-secret ANTHROPIC_API_KEY "sk-ant-your-anthropic-key"
ai-add-secret OPENAI_API_KEY "sk-your-openai-key"  
ai-add-secret GEMINI_API_KEY "your-gemini-key"
ai-add-secret GITHUB_TOKEN "ghp_your-github-token"
```

### 3. Verify Setup

```bash
# Check what secrets are configured and stored
ai-list-secrets

# Run AI diagnostics 
ai-doctor
```

## Managing Secrets

### Adding Secrets

```bash
ai-add-secret <KEY_NAME> <SECRET_VALUE>

# Examples:
ai-add-secret ANTHROPIC_API_KEY "sk-ant-api03-your-key-here"
ai-add-secret OPENAI_API_KEY "sk-proj-your-openai-key"
ai-add-secret GROQ_API_KEY "gsk_your-groq-key"
```

### Listing Secrets

```bash
ai-list-secrets
```

Output example:
```
AI Tool Secret Keys (configured in nix-config):
  ✓ ANTHROPIC_API_KEY
  ✓ OPENAI_API_KEY
  ✗ GEMINI_API_KEY (not in keychain)
  ✗ GROQ_API_KEY (not in keychain)
  ✓ GITHUB_TOKEN
```

### Removing Secrets

```bash
ai-remove-secret <KEY_NAME>

# Example:
ai-remove-secret ANTHROPIC_API_KEY
```

### Manual Secret Sourcing

```bash
# Source secrets manually (usually automatic)
ai-source-secrets

# Debug secret loading
ai-source-secrets --debug
```

## Supported API Keys

The following environment variables are preconfigured:

| Environment Variable | Service | Notes |
|---------------------|---------|-------|
| `ANTHROPIC_API_KEY` | Claude/Anthropic | For claude-code, fabric patterns |
| `OPENAI_API_KEY` | OpenAI | For ChatGPT, GPT-4, etc. |
| `GEMINI_API_KEY` | Google Gemini | For gemini-cli |
| `GROQ_API_KEY` | Groq | Fast inference API |
| `TOGETHER_API_KEY` | Together AI | Open source models |
| `PERPLEXITY_API_KEY` | Perplexity | Search-enhanced AI |
| `MISTRAL_API_KEY` | Mistral AI | European AI provider |
| `COHERE_API_KEY` | Cohere | NLP and embeddings |
| `HUGGINGFACE_API_KEY` | Hugging Face | Open source models, datasets |
| `GITHUB_TOKEN` | GitHub | For Copilot, repo access |

### Adding Custom Keys

To support additional API keys, update your nix configuration:

```nix
programs.ai.secrets = {
  enable = true;
  keys = [
    "ANTHROPIC_API_KEY"
    "OPENAI_API_KEY"
    "YOUR_CUSTOM_KEY"  # Add your custom key here
    # ... other keys
  ];
};
```

## How It Works

### Keychain Storage

- Secrets are stored as generic keychain items
- Service name format: `ai-tools-{KEY_NAME}`
- Account: your username (`$USER`)
- Access requires Touch ID or password

### Shell Integration

When enabled, secrets are automatically sourced in new shell sessions via:

```bash
# Added to your shell RC file
eval "$(ai-source-secrets)"
```

### Manual Keychain Access

You can also use macOS's `security` command directly:

```bash
# Add a secret manually
security add-generic-password -s "ai-tools-CUSTOM_KEY" -a "$USER" -w "your-secret"

# Retrieve a secret manually  
security find-generic-password -s "ai-tools-ANTHROPIC_API_KEY" -w

# Delete a secret manually
security delete-generic-password -s "ai-tools-ANTHROPIC_API_KEY"
```

## Security Best Practices

### ✅ Do's

- **Use strong, unique API keys** for each service
- **Regularly rotate API keys** (set calendar reminders)
- **Use scoped tokens** with minimal required permissions
- **Monitor API usage** for unexpected activity
- **Enable Touch ID** for keychain access

### ❌ Don'ts

- **Don't commit API keys** to git (use secrets management instead)
- **Don't share API keys** via insecure channels (Slack, email)
- **Don't use production keys** for testing/development
- **Don't store keys in plain text** files or shell history

## Troubleshooting

### Secrets Not Loading

1. **Check if secret management is enabled:**
   ```bash
   ai-list-secrets
   ```

2. **Verify keychain access:**
   ```bash
   ai-source-secrets --debug
   ```

3. **Check shell integration:**
   ```bash
   echo $ANTHROPIC_API_KEY
   ```

4. **Manually source secrets:**
   ```bash
   eval "$(ai-source-secrets)"
   echo $ANTHROPIC_API_KEY
   ```

### Touch ID Issues

If Touch ID prompts are annoying, you can configure keychain access in System Preferences:

1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Accessibility** 
3. Ensure Terminal/Warp has permission

### Key Not Found Errors

```bash
# Check if the key exists in keychain
security find-generic-password -s "ai-tools-ANTHROPIC_API_KEY"

# Re-add the key if missing
ai-add-secret ANTHROPIC_API_KEY "sk-ant-your-key"
```

## Alternative Approaches

While this setup uses macOS Keychain, you can also use:

### 1Password CLI

```bash
# Install 1Password CLI
brew install 1password-cli

# Use in shell scripts
export ANTHROPIC_API_KEY="$(op read "op://Private/Anthropic API Key/credential")"
```

### agenix (NixOS Standard)

For cross-platform compatibility, consider implementing agenix:

```nix
# Add to flake.nix inputs
inputs.agenix.url = "github:ryantm/agenix";

# Use encrypted secrets
age.secrets.anthropic-key.file = ./secrets/anthropic-key.age;
```

## Integration Examples

### Using with Fabric AI

```bash
# After secrets are sourced
fabric --model anthropic/claude-3-sonnet-20240229 "Explain quantum computing"
```

### Using with Gemini CLI

```bash  
# After secrets are sourced
gemini "What's the weather like today?"
```

### Using with Claude Code

```bash
# After secrets are sourced
claude-code "Refactor this function to be more efficient"
```

## Configuration Reference

### Full Configuration Example

```nix
programs.ai.secrets = {
  enable = true;
  
  # Customize which keys to manage
  keys = [
    "ANTHROPIC_API_KEY"
    "OPENAI_API_KEY"
    "GEMINI_API_KEY" 
    "GITHUB_TOKEN"
    "CUSTOM_API_KEY"
  ];
  
  # Enable automatic sourcing in shell
  shellIntegration = true;
};
```

### Disable Automatic Sourcing

```nix  
programs.ai.secrets = {
  enable = true;
  shellIntegration = false;  # Manual sourcing only
};
```

Then manually source when needed:
```bash
eval "$(ai-source-secrets)"
```

This gives you full control over when API keys are available in your environment.