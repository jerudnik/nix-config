# MCP (Model Context Protocol) Integration

This document describes the MCP server integration for Claude Desktop, providing declarative configuration of AI tool connectivity through the nix-config system.

## Overview

The MCP integration enables Claude Desktop to connect to various external tools and data sources through the Model Context Protocol. This implementation provides:

- **Declarative Configuration**: MCP servers configured through Home Manager modules
- **Reproducible Setup**: All server binaries use Nix store paths
- **Secure Defaults**: Safe server selection with optional secrets support
- **Extensible Design**: Easy addition of new MCP servers

## Architecture

### System Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Claude.app    │    │  Home Manager   │    │  MCP Servers    │
│  (nix-darwin)   │───▶│   MCP Module    │───▶│ (mcp-servers-   │
│                 │    │                 │    │     nix)        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
      System                   User                 Nix Store
```

### Layer Separation

- **System Layer (nix-darwin)**: Installs Claude Desktop via declarative Homebrew
- **User Layer (Home Manager)**: Configures MCP servers and generates Claude config
- **Package Layer (Overlay)**: Provides MCP server packages via `mcp-servers-nix`

## Configuration

### Basic Setup

Enable MCP in your Home Manager configuration:

```nix
home.mcp = {
  enable = true;
  servers = {
    # Your MCP servers here
  };
};
```

### Server Configuration

Each MCP server requires three components:

```nix
servers.my-server = {
  command = "${pkgs.my-mcp-server}/bin/my-mcp-server";  # Binary path
  args = [ "arg1" "arg2" ];                             # Arguments (optional)
  env = {                                               # Environment (optional)
    MY_API_KEY = "value";
  };
};
```

### Current Default Servers

The integration includes five pre-configured servers:

#### 1. Filesystem Server
```nix
filesystem = {
  command = "${pkgs.python3}/bin/python3";
  args = [ 
    "${config.home.homeDirectory}/nix-config/modules/home/mcp/filesystem-server.py" 
    "${config.home.homeDirectory}" 
  ];
};
```
- **Purpose**: Safe file system access within home directory
- **Security**: Path-restricted to prevent unauthorized access
- **Implementation**: Custom Python script with JSON-RPC protocol

#### 2. GitHub Integration
```nix
github = {
  command = "${pkgs.github-mcp-server}/bin/server";
  args = [];
  env = {
    # GITHUB_TOKEN = "your-token";  # Optional for private repos
  };
};
```
- **Purpose**: GitHub API integration for repository operations
- **Authentication**: Works in read-only mode without token
- **Source**: Official GitHub MCP server from nixpkgs

#### 3. Git Operations
```nix
git = {
  command = "${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
  args = [];
};
```
- **Purpose**: Local git repository operations
- **Security**: No secrets required, works with any git repository
- **Source**: `mcp-servers-nix` package

#### 4. Time Utilities
```nix
time = {
  command = "${pkgs.mcp-servers.mcp-server-time}/bin/mcp-server-time";
  args = [];
};
```
- **Purpose**: Date, time, and timezone operations
- **Security**: No external connections, purely computational
- **Source**: `mcp-servers-nix` package

#### 5. Web Fetch
```nix
fetch = {
  command = "${pkgs.mcp-servers.mcp-server-fetch}/bin/mcp-server-fetch";
  args = [];
};
```
- **Purpose**: HTTP/HTTPS requests for web content
- **Security**: Outbound web requests only
- **Source**: `mcp-servers-nix` package

## Module Options Reference

### `home.mcp.enable`
- **Type**: `boolean`
- **Default**: `false`
- **Description**: Enable MCP servers for Claude Desktop

### `home.mcp.servers`
- **Type**: `attrsOf (submodule)`
- **Default**: `{}`
- **Description**: Attribute set of MCP server configurations

#### Server Submodule Options

##### `command`
- **Type**: `string`
- **Description**: Absolute path to server binary (prefer Nix store path)
- **Example**: `"${pkgs.my-server}/bin/my-server"`

##### `args`
- **Type**: `listOf string`
- **Default**: `[]`
- **Description**: Arguments to pass to the MCP server
- **Example**: `[ "--config" "/path/to/config" ]`

##### `env`
- **Type**: `attrsOf string`
- **Default**: `{}`
- **Description**: Environment variables for the server
- **Example**: `{ API_KEY = "secret"; DEBUG = "1"; }`

### `home.mcp.configPath`
- **Type**: `string`
- **Default**: `"Library/Application Support/Claude/claude_desktop_config.json"`
- **Description**: Relative path from home directory to Claude Desktop MCP config

### `home.mcp.additionalConfig`
- **Type**: `attrs`
- **Default**: `{}`
- **Description**: Additional configuration to merge into Claude Desktop config

## File Locations

### Generated Configuration
The module generates Claude Desktop's configuration file:
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

### Custom Filesystem Server
```
~/nix-config/modules/home/mcp/filesystem-server.py
```

## Security Considerations

### Path Restrictions
The filesystem server is restricted to operate within the user's home directory:
```python
def is_path_allowed(self, path_str: str) -> bool:
    try:
        path = Path(path_str).resolve()
        return path.is_relative_to(self.allowed_path)
    except:
        return False
```

### Safe Server Selection
Default servers are chosen for security:
- **No secrets required**: Initial setup works without API keys
- **Limited scope**: Servers operate within defined boundaries
- **Read-only operations**: Most servers don't modify system state

### Optional Secrets
Advanced servers can be configured with secrets:
```nix
servers.advanced-server = {
  command = "${pkgs.advanced-mcp-server}/bin/server";
  env = {
    API_KEY = config.programs.ai.secrets.api-keys.my-service;  # Future integration
  };
};
```

## Usage Examples

### Testing MCP Servers

Verify server functionality:
```bash
# Test filesystem server
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"roots": {"listChanged": true}}, "clientInfo": {"name": "test", "version": "1.0.0"}}}' | python3 ~/nix-config/modules/home/mcp/filesystem-server.py ~

# Test git server
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"roots": {"listChanged": true}}, "clientInfo": {"name": "test", "version": "1.0.0"}}}' | ${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git
```

### Claude Desktop Usage

In Claude Desktop, you can:

1. **File Operations**: Ask Claude to read files or list directories in your home folder
2. **Git Integration**: Request git status, commit history, or repository information  
3. **Time Queries**: Ask for current time, timezone conversions, or date calculations
4. **Web Requests**: Request Claude to fetch content from URLs
5. **GitHub Operations**: Query GitHub repositories (with token for private repos)

Example prompts:
- "What files are in my Documents folder?"
- "Show me the recent commits in this git repository"
- "What time is it in Tokyo right now?"
- "Fetch the content from https://example.com"
- "What are the open issues in the nixpkgs repository?"

## Adding New MCP Servers

### From mcp-servers-nix

1. Check available servers:
   ```bash
   nix search github:natsukium/mcp-servers-nix
   ```

2. Add to configuration:
   ```nix
   servers.new-server = {
     command = "${pkgs.mcp-servers.mcp-server-new}/bin/mcp-server-new";
     args = [ /* server-specific args */ ];
   };
   ```

### From nixpkgs

```nix
servers.nixpkgs-server = {
  command = "${pkgs.some-mcp-server}/bin/server";
  args = [];
};
```

### Custom Servers

For custom servers, add to the overlay or create a local derivation:

```nix
servers.custom-server = {
  command = "${pkgs.python3}/bin/python3";
  args = [ ./my-custom-server.py ];
};
```

## Troubleshooting

### Server Not Connecting

1. **Check binary exists**:
   ```bash
   ls -la $(nix-build '<nixpkgs>' -A mcp-servers.mcp-server-git)/bin/
   ```

2. **Test server manually**:
   ```bash
   echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}}' | /path/to/server
   ```

3. **Check Claude Desktop logs**:
   ```bash
   log stream --predicate 'process contains "Claude"'
   ```

### Configuration Not Loading

1. **Verify file generation**:
   ```bash
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. **Check Home Manager activation**:
   ```bash
   home-manager switch --flake ~/nix-config#jrudnik@parsley
   ```

### Permission Issues

The filesystem server may encounter permission errors:
- Ensure the home directory is accessible
- Check that the server script has execute permissions
- Verify Python can access the specified paths

## Implementation Details

### JSON Generation

The module uses Nix's `builtins.toJSON` to generate Claude's configuration:

```nix
home.file.${cfg.configPath}.text = builtins.toJSON ({
  mcpServers = mapAttrs (n: v: {
    command = v.command;
    args = v.args;
    env = v.env;
  }) cfg.servers;
} // cfg.additionalConfig);
```

### Package Overlay

MCP servers are provided via overlay:
```nix
overlays = {
  mcp-servers = final: prev: {
    mcp-servers = inputs.mcp-servers-nix.packages.${prev.system} or {};
  };
};
```

### Home Manager Integration

The MCP module integrates with Home Manager's file management:
- Configuration file is managed declaratively
- Changes trigger automatic regeneration
- No manual file management required

## Related Documentation

- **[WARP.md](../../WARP.md)**: Mandatory configuration rules and compliance requirements  
- **[Architecture](architecture.md)**: Overall system architecture and design patterns
- **[Module Options](module-options.md)**: Complete reference for all module options
- **[AI Tools Inventory](../guides/ai-tools.md)**: Available AI tools and their nixpkgs status

## Future Enhancements

- **Secrets Integration**: Integration with macOS Keychain for API keys
- **Server Discovery**: Automatic detection of available MCP servers
- **Configuration Validation**: Pre-deployment server configuration testing
- **Performance Monitoring**: MCP server health and performance metrics
- **Advanced Servers**: Additional servers as the MCP ecosystem grows