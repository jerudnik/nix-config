# MCP Multi-Tool Usage Guide

How to extend your existing MCP configuration to work with multiple AI tools.

## 🎯 **Your Goal: Universal MCP Infrastructure**

You want to make your current MCP servers (filesystem, github, git, time, fetch) easily available to:
- **Claude Desktop** (current setup - preserved)
- **Continue.dev** (VS Code/JetBrains extension) 
- **Cursor** (AI code editor)
- **Gemini CLI** (when MCP support arrives)

## 🚀 **Simple Setup**

### **1. Import the Distribution Module**

Add to your `home/jrudnik/home.nix`:

```nix
{
  imports = [
    # ... your existing imports ...
    ../modules/home/mcp/distribution.nix  # NEW: Multi-tool support
  ];
}
```

### **2. Enable Multi-Tool Distribution** 

In your existing MCP configuration:

```nix
home.mcp = {
  enable = true;
  
  # Your existing servers (unchanged!)
  servers = {
    filesystem = {
      command = "${pkgs.python3}/bin/python3";
      args = [ "${../modules/home/mcp/filesystem-server.py}" "${config.home.homeDirectory}" ];
    };
    github = {
      command = "${pkgs.github-mcp-server}/bin/server";
      env = { GITHUB_TOKEN = "your_token"; };
    };
    git = {
      command = "${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
    };
    time = {
      command = "${pkgs.mcp-servers.mcp-server-time}/bin/mcp-server-time";
    };
    fetch = {
      command = "${pkgs.mcp-servers.mcp-server-fetch}/bin/mcp-server-fetch";
    };
  };
  
  # NEW: Multi-tool distribution
  tools = {
    # Claude Desktop (automatically configured - no changes needed!)
    
    # Continue.dev for VS Code
    continue = {
      enable = true;
      configPath = ".continue/config.json";
      format = "continue";
      # Only safe servers for Continue.dev
      serverFilter = [ "git" "time" "filesystem" ];
    };
    
    # Cursor AI editor
    cursor = {
      enable = true; 
      configPath = ".cursor/config.json";
      format = "cursor";
      # All servers available
    };
    
    # Gemini CLI (future - ready to enable when support arrives)
    gemini = {
      enable = false;
      configPath = ".config/gemini/mcp.json";
      format = "gemini";
    };
  };
  
  # Optional: Enable registry for debugging
  registry = true;
};
```

## 🔧 **What This Does**

### **Preserves Your Current Setup**
- ✅ Claude Desktop continues working exactly as before
- ✅ All your existing servers remain unchanged
- ✅ Same configuration file location

### **Extends to New Tools**
- 🔧 **Continue.dev**: Gets `~/.continue/config.json` in Continue format
- 🔧 **Cursor**: Gets `~/.cursor/config.json` in Cursor format  
- 🔧 **Gemini**: Ready for `~/.config/gemini/mcp.json` when enabled

### **Adds Management Tools**
- 📊 `mcp-tools status` - Show all tool configurations
- ✅ `mcp-tools check` - Verify config files exist
- 📋 `mcp-tools list` - List servers and tools

## 🎮 **Usage Examples**

### **Basic Multi-Tool Setup**
```nix
# Just add Continue.dev to your existing setup
home.mcp.tools.continue = {
  enable = true;
  configPath = ".continue/config.json";
  format = "continue";
};
```

### **Restricted Server Access**
```nix  
# Only allow safe servers for a specific tool
home.mcp.tools.continue = {
  enable = true;
  configPath = ".continue/config.json";
  format = "continue";
  serverFilter = [ "git" "time" ];  # No filesystem or github access
};
```

### **Tool-Specific Configuration**
```nix
# Add tool-specific settings
home.mcp.tools.cursor = {
  enable = true;
  configPath = ".cursor/config.json"; 
  format = "cursor";
  additionalConfig = {
    # Cursor-specific settings
    timeout = 30000;
    retries = 3;
  };
};
```

## 📂 **Generated Files**

After `home-manager switch`, you'll have:

```
~/Library/Application Support/Claude/claude_desktop_config.json  # Claude Desktop (existing)
~/.continue/config.json                                          # Continue.dev (new)
~/.cursor/config.json                                           # Cursor (new)
~/.config/mcp/registry.json                                     # Debug registry (optional)
```

## 🧪 **Testing the Setup**

### **1. Check Configuration**
```bash
mcp-tools status
# Shows all tools and their status

mcp-tools check  
# Verifies config files exist

mcp-tools list
# Lists servers and tools
```

### **2. Test Continue.dev**
1. Install Continue.dev extension in VS Code
2. Your servers should be automatically available
3. Try: "List files in my current project" (uses filesystem server)

### **3. Test Cursor**
1. Download and install Cursor
2. Your servers should be automatically detected
3. Try: "Show recent git commits" (uses git server)

## 🔧 **Tool-Specific Notes**

### **Continue.dev**
- **Installation**: VS Code extension marketplace
- **Usage**: `Cmd+I` to start Continue chat
- **MCP Commands**: `/mcp <your request>` 
- **Best servers**: git, time, filesystem (safe operations)

### **Cursor**
- **Installation**: Download from cursor.sh
- **Usage**: `Cmd+K` for AI chat with MCP context
- **Integration**: Automatic server detection
- **Best servers**: All servers work well

### **Gemini CLI**
- **Status**: Future support (MCP not yet available)
- **Ready**: Configuration prepared for when support arrives
- **Enable**: Just change `enable = false` to `enable = true`

## 🚀 **Benefits**

### **Universal Infrastructure**
- ✅ Same servers work across all AI tools
- ✅ Single source of truth for server configuration
- ✅ Easy to add new tools as they gain MCP support

### **Efficient Resource Usage**
- 🔄 Share expensive operations (GitHub API calls)
- 📊 Consistent context across tools
- 🛠 Centralized management

### **Future-Proof**
- 🔮 Ready for new AI tools as they add MCP support
- 📈 Easy to extend with more servers
- 🎯 Scales from 1 tool to many tools seamlessly

## 💡 **Getting Started**

**Recommended first step**: Just enable Continue.dev to test multi-tool distribution:

```nix
home.mcp.tools.continue = {
  enable = true;
  configPath = ".continue/config.json";
  format = "continue";
  serverFilter = [ "git" "time" ];  # Start with safe servers
};
```

Then run `home-manager switch` and test in VS Code!

This approach gives you a **universal MCP infrastructure** that works consistently across all your AI tools. 🌟