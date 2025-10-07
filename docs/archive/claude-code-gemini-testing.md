# Claude Code & Gemini CLI Testing Guide

Quick guide to test your new terminal AI tools with MCP integration.

## 🚀 **Setup**

### **1. Apply Configuration**

```bash
cd ~/nix-config
home-manager switch
```

This will:
- ✅ Install `claude-code` from nixpkgs (command: `claude`)
- ✅ Install `gemini-cli` from nixpkgs (command: `gemini`)
- ✅ Configure MCP distribution to both tools
- ✅ Create shell aliases and environment setup

### **2. Verify Installation**

```bash
# Check commands are available
which claude
which gemini

# Check versions
claude --version
gemini --version

# Check MCP configs were generated
ls -la ~/.config/claude-code/mcp.json
ls -la ~/.config/gemini-cli/mcp.json
```

## 🧪 **Testing Claude Code CLI**

### **Basic Usage**

```bash
# Get help
claude --help

# Start an interactive session
claude

# Quick one-off question
claude "Explain this nix configuration"

# In your nix-config directory
cd ~/nix-config
claude "What MCP servers are configured in this project?"
```

### **Test MCP Integration**

```bash
# Claude Code should have access to your MCP servers:
# - filesystem
# - github  
# - git
# - time
# - fetch

# Test filesystem server
claude "List the files in my current directory"

# Test git server
claude "Show me recent git commits in this repository"

# Test time server
claude "What's the current date and time?"
```

### **Configuration Check**

```bash
# View MCP configuration
cat ~/.config/claude-code/mcp.json | jq '.'

# Check MCP registry
cat ~/.config/mcp/registry.json | jq '.'
```

## 🧪 **Testing Gemini CLI**

### **API Key Setup**

```bash
# Get API key from: https://aistudio.google.com/app/apikey

# Set environment variable (add to ~/.zshrc for persistence)
export GEMINI_API_KEY='your_api_key_here'

# Verify
echo $GEMINI_API_KEY
```

### **Basic Usage**

```bash
# Get help
gemini --help

# Quick question
gemini "Hello, can you hear me?"

# Interactive chat
gemini chat

# With model specification
gemini --model gemini-1.5-pro "Explain Nix flakes"
```

### **Test MCP Integration**

```bash
# Gemini should have access to your MCP servers

cd ~/nix-config

# Test filesystem server
gemini "What files are in this directory?"

# Test git server  
gemini "Show me the git history for this repository"

# Test github server (if GITHUB_TOKEN is set)
gemini "What are the recent issues in this GitHub repository?"

# Test time server
gemini "What time is it?"

# Test fetch server
gemini "Fetch the content from https://example.com"
```

### **Configuration Check**

```bash
# View MCP configuration
cat ~/.config/gemini-cli/mcp.json | jq '.'

# Use shell alias
gai "Quick test"
```

## 🔧 **Troubleshooting**

### **Commands Not Found**

```bash
# Rebuild configuration
cd ~/nix-config
home-manager switch

# Check PATH
echo $PATH | tr ':' '\n' | grep nix

# Try with full path
/nix/store/*/bin/claude --version
/nix/store/*/bin/gemini --version
```

### **MCP Not Working**

```bash
# Check MCP tools status
mcp-tools status

# Verify config files exist
ls -la ~/.config/claude-code/
ls -la ~/.config/gemini-cli/
ls -la ~/.config/mcp/

# Check MCP registry
cat ~/.config/mcp/registry.json | jq '.tools'

# Regenerate configs
home-manager switch
```

### **Gemini API Key Issues**

```bash
# Check if key is set
echo $GEMINI_API_KEY

# Add to shell permanently
echo 'export GEMINI_API_KEY="your_key_here"' >> ~/.zshrc
source ~/.zshrc

# Or use the secrets module (recommended)
# See: modules/home/ai/infrastructure/secrets.nix
```

### **Claude Code Issues**

```bash
# Check if ANTHROPIC_API_KEY is needed
echo $ANTHROPIC_API_KEY

# Claude Code typically uses:
export ANTHROPIC_API_KEY='your_anthropic_key_here'
```

## ✅ **Success Criteria**

You should be able to:

1. **Claude Code CLI**:
   ```bash
   claude "List files in current directory"
   # Should use filesystem MCP server
   ```

2. **Gemini CLI**:
   ```bash
   gemini "What git changes have I made?"
   # Should use git MCP server
   ```

3. **Cross-Tool Consistency**:
   ```bash
   # Same question to both tools
   claude "Describe this nix configuration"
   gemini "Describe this nix configuration"
   
   # Both should have access to same MCP servers
   ```

4. **MCP Registry**:
   ```bash
   cat ~/.config/mcp/registry.json | jq '.tools'
   # Should show: claude, claude-code, gemini
   ```

## 🌟 **Advanced Usage**

### **Shell Aliases**

```bash
# Quick aliases are automatically configured:
cc "question"           # Shortcut for claude
gai "question"          # Shortcut for gemini
gemini-chat            # Start interactive Gemini chat
```

### **MCP Status**

```bash
# Check all MCP configurations
mcp-tools status
mcp-tools list
mcp-tools check
```

### **Multi-Tool Workflow**

```bash
# Same project, different AI perspectives:
cd ~/nix-config

# Ask Claude Code
claude "What's the architecture of this nix configuration?"

# Ask Gemini
gemini "Analyze the modular structure of this nix setup"

# Both use same MCP servers for consistent context!
```

## 📊 **Expected Output**

After successful setup:

```bash
$ mcp-tools status
=== MCP Multi-Tool Status ===
Servers: filesystem, github, git, time, fetch
Tools: claude, claude-code, gemini

$ claude "What's in this directory?"
[Uses filesystem MCP server to list files]

$ gemini "Show git log"
[Uses git MCP server to show commits]
```

This setup gives you **terminal-based AI assistants** that share your MCP infrastructure! 🚀