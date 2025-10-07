# Multi-Tool MCP Integration Guide

Complete guide for using MCP (Model Context Protocol) servers across multiple AI tools and applications.

## Overview

Your current MCP setup is designed specifically for Claude Desktop, but MCP is a **universal protocol** that works with many AI tools. This guide shows you how to extend your configuration to support multiple applications simultaneously.

## Supported AI Tools

### 🤖 **Currently Working**
- **Claude Desktop** ✅ (your current setup)
- **Continue.dev** ✅ (VS Code/JetBrains extension) 
- **Cursor** ✅ (AI code editor)
- **Codeium** ✅ (AI code assistant)
- **Generic MCP clients** ✅

### 🚧 **Coming Soon**
- **GitHub Copilot Chat** (when MCP support is added)
- **TabNine** (when MCP support is added)
- **Cody** (Sourcegraph's AI assistant)

## Quick Start: Enable Multi-Tool Support

### 1. **Add Multi-Tool Configuration to Your Home Config**

```nix
# In home/jrudnik/home.nix
home.mcp = {
  enable = true;
  
  # Your existing servers
  servers = {
    filesystem = { /* ... */ };
    github = { /* ... */ };
    git = { /* ... */ };
    time = { /* ... */ };
    fetch = { /* ... */ };
  };
  
  # NEW: Enable multi-tool support
  multiTool = {
    enable = true;
    standalone = true;  # Servers run independently
    
    toolConfigs = {
      # Claude Desktop (existing)
      claude = {
        enable = true;
        configPath = "Library/Application Support/Claude/claude_desktop_config.json";
        format = "claude";
      };
      
      # Continue.dev (VS Code/JetBrains)
      continue = {
        enable = true;
        configPath = ".continue/config.json";
        format = "continue";
      };
      
      # Cursor (AI code editor)
      cursor = {
        enable = true;
        configPath = ".cursor/config.json";
        format = "cursor";
      };
      
      # Codeium integration
      codeium = {
        enable = true;
        configPath = ".codeium/config.json";
        format = "codeium";
      };
    };
  };
};
```

### 2. **Apply Configuration**

```bash
cd ~/nix-config
./scripts/build.sh switch
```

### 3. **Test Multi-Tool Setup**

```bash
# Check server status
mcp-server-manager status

# Start all servers
mcp-server-manager start

# List available tools
mcp-server-manager config
```

## Tool-Specific Setup

### 📋 **Continue.dev (VS Code Extension)**

**Installation:**
1. Install Continue.dev extension in VS Code
2. Your nix config automatically creates `~/.continue/config.json`
3. Restart VS Code

**Usage:**
- Press `Cmd+I` to start Continue chat
- Use `/mcp` command to query MCP servers
- Access filesystem, GitHub, git operations through Continue

**Example Continue Commands:**
```
/mcp list files in my project
/mcp show recent git commits
/mcp fetch https://api.github.com/repos/owner/repo
```

### 🎯 **Cursor (AI Code Editor)**

**Installation:**
1. Download Cursor from cursor.sh
2. Your nix config creates `~/.cursor/config.json`
3. Restart Cursor

**Usage:**
- Cursor automatically detects MCP servers
- Use Cmd+K for AI chat with MCP context
- MCP servers provide additional context for code generation

### 🔧 **Codeium (AI Assistant)**

**Installation:**
1. Install Codeium extension in your editor
2. Configuration file created automatically
3. Restart your editor

**Usage:**
- Codeium uses MCP servers for enhanced context
- Available in VS Code, JetBrains, Vim/Neovim

## Universal Server Management

### **Server Manager Commands**

```bash
# Start/stop servers
mcp-server-manager start           # Start all servers
mcp-server-manager start github    # Start specific server
mcp-server-manager stop            # Stop all servers
mcp-server-manager restart         # Restart all servers

# Monitor servers
mcp-server-manager status          # Show running status
mcp-server-manager logs            # View all server logs
mcp-server-manager logs filesystem # View specific server logs

# Configuration
mcp-server-manager list            # List available servers
mcp-server-manager config          # Show configuration summary
```

### **Server Lifecycle**

**Automatic Management (Default):**
- Servers start when AI tools launch
- Each tool manages its own server connections
- Servers stop when tools exit

**Standalone Mode:**
- Servers run independently of AI tools
- Multiple tools can connect to same servers
- Better resource efficiency
- Manual start/stop control

## Configuration Files Generated

Your enhanced setup creates configurations for each tool:

```
~/.config/mcp/servers.json                                    # Universal config
~/Library/Application Support/Claude/claude_desktop_config.json  # Claude Desktop
~/.continue/config.json                                       # Continue.dev
~/.cursor/config.json                                         # Cursor
~/.codeium/config.json                                        # Codeium
```

## Advanced Configuration

### **Custom Tool Integration**

Add support for new MCP-compatible tools:

```nix
home.mcp.multiTool.toolConfigs.myTool = {
  enable = true;
  configPath = ".mytool/mcp.json";
  format = "generic";
  additionalConfig = {
    # Tool-specific settings
    apiVersion = "1.0";
    features = ["filesystem" "git"];
  };
};
```

### **Server-Specific Tool Access**

Restrict certain servers to specific tools:

```nix
# Advanced server configuration with tool restrictions
home.mcp.servers.sensitive-server = {
  command = "/path/to/server";
  args = [];
  env = { API_KEY = "secret"; };
  
  # Only available to specific tools
  enabledTools = ["claude" "cursor"];  # Not available to continue.dev
};
```

### **Performance Tuning**

```nix
home.mcp.multiTool = {
  enable = true;
  standalone = true;
  
  # Tune server ports to avoid conflicts
  serverPort = 8080;  # Base port, servers get 8080, 8081, 8082...
  
  # Resource limits (when standalone = true)
  serverLimits = {
    maxMemory = "512MB";
    maxCpuPercent = 50;
    restartOnFailure = true;
  };
};
```

## Troubleshooting

### **Servers Not Starting**

```bash
# Check server status
mcp-server-manager status

# View detailed logs
mcp-server-manager logs

# Manual server testing
/nix/store/.../bin/mcp-server-git --help
```

### **Tool Not Detecting Servers**

**Continue.dev:**
1. Check `~/.continue/config.json` exists
2. Restart VS Code
3. Enable Continue.dev extension
4. Check VS Code output panel for errors

**Cursor:**
1. Verify `~/.cursor/config.json` is created  
2. Restart Cursor completely
3. Check Cursor settings for MCP configuration

**Claude Desktop:**
1. Ensure Claude Desktop is installed via Homebrew
2. Check config file location
3. Restart Claude Desktop

### **Configuration Conflicts**

```bash
# Check which tools are configured
mcp-server-manager config

# Verify configuration files
ls -la ~/.config/mcp/
ls -la ~/.continue/
ls -la ~/.cursor/
```

## Migration from Claude-Only Setup

Your existing Claude-only configuration continues to work unchanged. The multi-tool enhancement:

✅ **Preserves** existing Claude Desktop functionality  
✅ **Extends** servers to other tools  
✅ **Maintains** backward compatibility  
✅ **Adds** universal server management  

## Benefits of Multi-Tool Setup

### 🚀 **Enhanced Productivity**
- Use MCP servers across all AI tools
- Consistent context across applications
- No need to re-configure servers for each tool

### 🔧 **Better Resource Management**  
- Standalone servers avoid duplication
- Share expensive operations (GitHub API calls)
- Centralized logging and monitoring

### 📈 **Scalability**
- Easy to add new AI tools
- Universal configuration format
- Future-proof architecture

## What's Next

1. **Try it out**: Enable multi-tool support and test with Continue.dev
2. **Customize**: Configure servers for your specific workflow  
3. **Extend**: Add support for new tools as they gain MCP compatibility
4. **Share**: Your multi-tool setup can be a template for others

This multi-tool approach makes your MCP servers truly universal, providing consistent AI assistance across your entire development environment! 🌟