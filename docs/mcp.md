# MCP (Model Context Protocol) Integration

## Overview

This configuration uses **mcp-servers-nix** for declarative MCP server management, providing Claude Desktop (and other AI tools) with filesystem access, GitHub integration, Git operations, and more.

**Implementation**: Fully declarative, reproducible MCP server configuration via Nix flakes  
**Status**: ✅ Production-ready  
**Last Updated**: 2025-10-07

---

## What is MCP?

Model Context Protocol (MCP) is an open protocol that enables AI assistants to securely interact with external data sources and tools. It provides:

- **Filesystem access**: Read/write files within allowed directories
- **GitHub integration**: Search code, create issues, read PRs
- **Git operations**: Repository history, diffs, branches
- **Time utilities**: Current time, date calculations
- **Web fetch**: HTTP requests and web scraping

---

## Current Implementation

### Configuration Location

**Primary**: `home/jrudnik/home.nix` (lines 178-204)

```nix
home.file."Library/Application Support/Claude/claude_desktop_config.json".source =
  inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      filesystem = {
        enable = true;
        args = [ config.home.homeDirectory ];
      };
      github.enable = true;
      git.enable = true;
      time.enable = true;
      fetch.enable = true;
    };
  };
```

### Enabled MCP Servers

| Server | Purpose | Authentication |
|--------|---------|----------------|
| **filesystem** | File operations in home directory | None (path-restricted) |
| **github** | GitHub API access (read-only works without token) | Optional: `gh auth token` |
| **git** | Local repository operations | None |
| **time** | Date/time utilities | None |
| **fetch** | HTTP requests | None |

### Why mcp-servers-nix?

**Benefits over manual configuration:**
1. ✅ **Declarative**: Configuration in Nix, not JSON files
2. ✅ **Reproducible**: Exact package versions pinned
3. ✅ **Type-safe**: Nix validates configuration
4. ✅ **Integrated**: Works seamlessly with flake inputs
5. ✅ **Maintained**: Community-driven updates

**Previous approach** (now deprecated):
- Custom Python scripts
- Manual JSON configuration
- Mixed package sources
- Difficult to maintain

---

## Architecture

### Directory Structure

```
modules/home/ai/
├── infrastructure/
│   ├── default.nix           # Infrastructure imports
│   └── secrets.nix            # macOS Keychain secrets
├── interfaces/
│   ├── claude-desktop.nix     # (disabled - using Homebrew cask)
│   └── ...other interfaces
└── patterns/fabric/           # Fabric AI patterns
```

### Configuration Flow

```
flake.nix
  ↓ (inputs.mcp-servers-nix)
  ↓
home/jrudnik/home.nix
  ↓ (mkConfig generates JSON)
  ↓
~/Library/Application Support/Claude/claude_desktop_config.json
  ↓
Claude Desktop reads on startup
```

---

## Usage Examples

### Filesystem Operations

```
Human: List all Python files in my nix-config directory

Claude: [uses filesystem server]
       nix-config/
       ├── modules/home/mcp/filesystem-server.py (deleted)
       └── [shows current Python files if any]
```

### GitHub Integration

```
Human: Search for "mcp-servers" in the natsukium/mcp-servers-nix repository

Claude: [uses github server]
        Found X references...
```

### Git Operations

```
Human: Show me the last 5 commits in my current repository

Claude: [uses git server]
        - commit abc123: "Add fabric-ai integration"
        - commit def456: "Migrate to mcp-servers-nix"
        ...
```

---

## Adding/Modifying Servers

### Enable Additional Server

Edit `home/jrudnik/home.nix`:

```nix
home.file."Library/Application Support/Claude/claude_desktop_config.json".source =
  inputs.mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      # Existing servers...
      
      # Add new server
      postgres = {
        enable = true;
        args = [ "--connection-string" "postgresql://..." ];
      };
    };
  };
```

### Configure Authentication

For servers requiring authentication (e.g., GitHub with write access):

```nix
github = {
  enable = true;
  passwordCommand.GITHUB_TOKEN = [ "gh" "auth" "token" ];
};
```

This securely retrieves the token from `gh` CLI.

### Available Servers

See [mcp-servers-nix documentation](https://github.com/natsukium/mcp-servers-nix) for full list of supported servers.

---

## Troubleshooting

### Claude Desktop Not Seeing Servers

1. **Restart Claude Desktop** after configuration changes
2. **Check config file**:
   ```bash
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq
   ```
3. **Verify Home Manager applied**:
   ```bash
   ls -la ~/Library/Application\ Support/Claude/
   ```

### Server Connection Errors

1. **Check server binary exists**:
   ```bash
   which npx  # For Node.js servers
   which python3  # For Python servers
   ```

2. **Test server manually**:
   ```bash
   npx @modelcontextprotocol/server-git --stdio
   ```

3. **Check Claude Desktop logs**:
   - Open Claude Desktop
   - Go to Settings → Advanced → View Logs
   - Look for MCP connection errors

### GitHub Authentication Issues

If GitHub server works read-only but you need write access:

```bash
# Authenticate with GitHub CLI
gh auth login

# Test token
gh auth token

# Verify in config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq '.mcpServers.github'
```

---

## Security Considerations

### Filesystem Server

- **Restricted to home directory** by default
- Cannot access `/etc`, `/System`, etc.
- Safe for general use

**To restrict further**:
```nix
filesystem = {
  enable = true;
  args = [ "${config.home.homeDirectory}/safe-directory" ];
};
```

### GitHub Server

- **Read-only without token** - safe for public repos
- **With token** - can create issues, PRs (use with caution)
- Token stored securely via `gh auth`

### General Best Practices

1. ✅ Only enable servers you actually use
2. ✅ Use `passwordCommand` for secrets, not hardcoded values
3. ✅ Review server capabilities before enabling
4. ✅ Keep mcp-servers-nix input updated for security patches

---

## Integration with Other Tools

### Fabric AI

Fabric AI patterns can reference MCP server outputs:

```bash
# Get file list via MCP, process with Fabric
cat file-list.txt | fabric --pattern code-to-docs
```

### AI Secret Management

API keys for AI tools managed via macOS Keychain:

```bash
# Store API key
ai-add-secret ANTHROPIC_API_KEY "sk-ant-..."

# List stored secrets
ai-list-secrets

# Remove secret
ai-remove-secret ANTHROPIC_API_KEY
```

See `modules/home/ai/infrastructure/secrets.nix` for implementation.

---

## Flake Input Configuration

### Current Version

```nix
# flake.nix
inputs = {
  mcp-servers-nix = {
    url = "github:natsukium/mcp-servers-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### Updating

```bash
# Update mcp-servers-nix to latest
nix flake update mcp-servers-nix

# Or update all inputs
./scripts/build.sh update
```

---

## Migration History

### From Custom Implementation (Oct 2025)

**Old approach**:
- Custom Python script: `modules/home/mcp/filesystem-server.py`
- Manual JSON generation
- Mixed package management

**Migration benefits**:
- Eliminated 300+ lines of custom code
- Improved reproducibility
- Better maintenance (community-driven)
- Type-safe configuration

**Migration was straightforward**:
1. Added mcp-servers-nix flake input
2. Replaced custom config with mkConfig
3. Deleted custom modules
4. Rebuild and test

See `docs/archive/mcp-migration-complete.md` for detailed migration notes.

---

## Resources

- **mcp-servers-nix**: https://github.com/natsukium/mcp-servers-nix
- **Model Context Protocol**: https://modelcontextprotocol.io/
- **Official MCP Servers**: https://github.com/modelcontextprotocol
- **Claude Desktop**: https://claude.ai/download

---

## Status Summary

✅ **Fully Functional**
- All servers working correctly
- Declarative configuration via Nix
- Integrated with Home Manager
- Production-ready

✅ **WARP.md Compliant**
- Using nixpkgs-first approach (mcp-servers-nix)
- No custom scripts or manual configuration
- Reproducible and hermetic
- Properly documented

✅ **Maintenance**
- Regular updates via `nix flake update`
- Community-maintained servers
- Security patches applied automatically

---

## Future Enhancements

**Potential additions**:
- PostgreSQL server (for database queries)
- Slack server (for workspace integration)
- Memory server (for persistent context)
- Custom domain-specific servers

**To add**: Simply enable in `home.nix` configuration, rebuild, restart Claude Desktop.
