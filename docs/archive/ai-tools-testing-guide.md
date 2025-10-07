# AI Tools Testing Guide

Step-by-step guide to set up and test Claude Code, Gemini CLI, and MCP integration.

## 🚀 **Quick Setup**

### **1. Add AI Integration to Your Home Configuration**

Add to your `home/jrudnik/home.nix`:

```nix
{
  imports = [
    # ... your existing imports ...
    ./ai-integration.nix  # NEW: AI tools + MCP integration
  ];
}
```

### **2. Apply Configuration**

```bash
cd ~/nix-config
home-manager switch
```

This will:
- ✅ Install VS Code with AI extensions
- ✅ Set up Gemini CLI installation script
- ✅ Configure MCP multi-tool distribution
- ✅ Create management commands (`ai-tools`, `mcp-tools`)

## 🧪 **Testing Phase 1: Basic Setup**

### **Check Installation Status**

```bash
# Check overall AI tools status
ai-tools status

# Check MCP configuration status  
mcp-tools status

# List available commands
ai --help
mcp --help
```

**Expected Output:**
```
=== AI Tools Status ===
✅ VS Code: Installed
🤖 Claude Code: Ready (install extension manually)
⚠️  Gemini CLI: Not installed (run 'install-gemini-cli')
✅ Claude Desktop: Installed

=== MCP Multi-Tool Status ===
Servers: filesystem, github, git, time, fetch
Tools: claude, claude-code, gemini
```

## 🧪 **Testing Phase 2: Gemini CLI**

### **Install Gemini CLI**

```bash
# Install Gemini CLI
install-gemini-cli

# Verify installation
gemini --version
```

### **Configure API Key**

1. **Get API key** from https://aistudio.google.com/app/apikey
2. **Set environment variable**:

```bash
# Add to ~/.zshrc (or set in your nix config)
export GEMINI_API_KEY='your_api_key_here'

# Reload shell
source ~/.zshrc

# Test API connection
gemini "Hello, can you see this?"
```

### **Test MCP Integration with Gemini**

```bash
# Check MCP config was generated
ls -la ~/.config/gemini-cli/
cat ~/.config/gemini-cli/mcp.json | jq '.'

# Test filesystem server
gemini "List the files in my current directory"

# Test git server  
cd ~/nix-config
gemini "What's the recent git history for this repository?"

# Test time server
gemini "What's the current date and time?"
```

## 🧪 **Testing Phase 3: Claude Code (VS Code)**

### **Install VS Code Extension**

1. **Open VS Code**: `code`
2. **Go to Extensions** (`Cmd+Shift+X`)
3. **Search for**: "VS Claude" or "Claude Code" 
4. **Install** the extension by Mario Zechner
5. **Reload** VS Code

### **Configure Claude Code**

1. **Open Command Palette** (`Cmd+Shift+P`)
2. **Run**: "VS Claude: Install MCP"
3. **Follow prompts** to configure
4. **Restart** VS Code

### **Test MCP Integration with Claude Code**

```bash
# Check MCP config was generated
ls -la ~/.vscode/mcp_settings.json
cat ~/.vscode/mcp_settings.json | jq '.'

# Open your nix-config in VS Code
cd ~/nix-config
code .

# Test in VS Code:
# 1. Open Command Palette (Cmd+Shift+P)
# 2. Look for Claude/MCP commands
# 3. Try: "Show files in current directory"
# 4. Try: "What git changes have I made?"
```

## 🧪 **Testing Phase 4: Integration Verification**

### **Verify All Configurations**

```bash
# Check all config files exist
mcp-tools check

# Debug any issues
cat ~/.config/mcp/registry.json | jq '.'

# Show detailed status
ai-tools status
mcp-tools status
```

### **Test Cross-Tool Consistency**

```bash
# Same question to different tools:

# 1. Claude Desktop (your existing setup)
# Ask: "List files in my home directory"

# 2. Gemini CLI
gemini "List files in my home directory"

# 3. Claude Code in VS Code
# Command: "List files in current project"

# All should use the same filesystem server!
```

## 🔧 **Troubleshooting**

### **Gemini CLI Issues**

```bash
# Check installation
which gemini
gemini --version

# Check API key
echo $GEMINI_API_KEY

# Reinstall if needed
npm uninstall -g @google/gemini-cli
install-gemini-cli
```

### **Claude Code Issues**

```bash
# Check VS Code extensions
code --list-extensions | grep claude

# Check MCP settings
ls -la ~/.vscode/mcp_settings.json

# Manual MCP setup
# Open VS Code → Command Palette → "VS Claude: Install MCP"
```

### **MCP Configuration Issues**

```bash
# Verify all config files
find ~/ -name "*mcp*" -type f 2>/dev/null

# Check file contents
for file in ~/.config/gemini-cli/mcp.json ~/.vscode/mcp_settings.json; do
  echo "=== $file ==="
  cat "$file" | jq '.' 2>/dev/null || cat "$file"
done

# Regenerate configurations
home-manager switch
```

## 🎯 **Success Criteria**

### **✅ Full Integration Working**

You should be able to:

1. **Gemini CLI**: 
   - `gemini "What files are in my current directory?"` → Uses filesystem server
   - `gemini "Show recent git commits"` → Uses git server

2. **Claude Code**: 
   - VS Code extension installed and connected to MCP
   - Can ask about files and git history through VS Code

3. **Claude Desktop**: 
   - Continues working exactly as before
   - Same servers, same functionality

4. **Management**: 
   - `ai-tools status` shows all tools ready
   - `mcp-tools status` shows all configurations

## 🌟 **Advanced Usage**

### **AI Workflow Commands**

```bash
# Quick AI chat
chat "How do I optimize this nix configuration?"

# Open AI workspace
code ~/ai-projects/ai-workspace.code-workspace

# MCP development environment
mcp-dev
```

### **Multi-Tool Development**

```bash
# Same project, different AI tools:
cd ~/nix-config

# Ask Gemini about architecture
gemini "Analyze this nix-darwin configuration structure"

# Ask Claude Code about specific files
# (In VS Code): "Explain this MCP configuration"

# Compare approaches and insights!
```

This setup gives you a **universal AI development environment** where all your AI tools share the same MCP servers and have consistent access to your development context! 🚀