# MCP Configuration Research - Multi-Tool Support

**Date:** 2025-01-07  
**Status:** Research Complete - Ready for Implementation

## Key Question

Can we create a unified MCP server configuration system where servers are defined once in Nix and automatically deployed to multiple AI tools (Claude Desktop, claude-code, gemini-cli)?

## Answer: **YES! (with some nuances)**

---

## Configuration Locations by Tool

### 1. **Claude Desktop** ✅ ACTIVE
- **Config Location:** `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
- **Format:** JSON with `mcpServers` object
- **Current Status:** Working via `home.mcp` module
- **Example:**
  ```json
  {
    "mcpServers": {
      "github": {
        "command": "/nix/store/.../bin/server",
        "args": [],
        "env": { "GITHUB_TOKEN": "..." }
      }
    }
  }
  ```

### 2. **claude-code CLI** ✅ COMPATIBLE
- **Config Locations** (in priority order):
  1. `.mcp.json` (project-specific, highest priority)
  2. `~/.claude.json` (global user config)
  3. `~/Library/Application Support/Claude/claude_desktop_config.json` (shared with Desktop)
- **Format:** Same JSON format as Claude Desktop
- **Key Insight:** **claude-code can share Claude Desktop's config file!** 🎉
- **Current Status:** Not yet configured in our system
- **Sources:** 
  - https://scottspence.com/posts/configuring-mcp-tools-in-claude-code
  - https://mcpcat.io/guides/adding-an-mcp-server-to-claude-code/

### 3. **gemini-cli** ⚠️ PARTIALLY COMPATIBLE
- **Config Location:** `settings.json` (location unclear, likely `~/.config/gemini-cli/` or project root)
- **Format:** Similar JSON with `mcpServers` array
- **Key Difference:** Uses `mcpServers` **array** instead of **object**
- **Example:**
  ```json
  {
    "mcpServers": [
      {
        "type": "stdio",
        "command": "your-mcp-server-command",
        "args": ["your-arguments"],
        "env": { "KEY": "value" }
      }
    ]
  }
  ```
- **Current Status:** Not installed in our system
- **Sources:**
  - https://gemini-cli.xyz/docs/en/tools/mcp-server
  - https://aiopsone.com/supercharging-gemini-cli-with-mcp-servers-the-missing-manual/

---

## Unified Configuration Strategy

### **Option A: Shared Config File (RECOMMENDED FOR CLAUDE TOOLS)**

**Approach:** Use a single `claude_desktop_config.json` for both Claude Desktop and claude-code.

**Pros:**
- ✅ Zero duplication for Claude ecosystem tools
- ✅ Single source of truth
- ✅ Works out-of-the-box (claude-code reads Claude Desktop config)
- ✅ Simpler module structure

**Cons:**
- ❌ Doesn't work for gemini-cli (different format)
- ❌ Tightly couples Claude tools

**Implementation:**
```nix
# modules/home/mcp/default.nix generates:
# ~/Library/Application Support/Claude/claude_desktop_config.json

# Both Claude Desktop and claude-code read it automatically!
```

### **Option B: Per-Tool Configs with Shared Server Definitions**

**Approach:** Define MCP servers once in Nix, generate tool-specific config files.

**Pros:**
- ✅ Works for all tools (Claude Desktop, claude-code, gemini-cli)
- ✅ Tool-specific customization possible
- ✅ Decoupled architectures
- ✅ Can enable servers per-tool

**Cons:**
- ⚠️ Slight duplication in generated files
- ⚠️ More complex module structure

**Implementation:**
```nix
# modules/home/mcp/default.nix
options.home.mcp = {
  servers = { /* define once */ };
  
  targets = {
    claudeDesktop.enable = true;
    claudeCode.enable = true;
    geminiCli.enable = true;
  };
};

config = {
  # Generate Claude Desktop config (object format)
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = ...;
  
  # Generate gemini-cli config (array format)
  home.file.".config/gemini-cli/settings.json" = ...;
  
  # claude-code can use Claude Desktop's config or its own .claude.json
};
```

### **Option C: Hybrid Approach (OPTIMAL BALANCE)**

**Approach:** Shared config for Claude tools, separate for others.

**Pros:**
- ✅ Simplicity for Claude ecosystem (shared file)
- ✅ Flexibility for non-Claude tools
- ✅ Minimal duplication
- ✅ Easy to understand

**Implementation:**
```nix
# modules/home/mcp/default.nix
options.home.mcp = {
  # Core server definitions
  servers = { /* shared definitions */ };
  
  # Claude tools share config automatically
  claude = {
    enable = true;  # Enables for both Desktop and Code
  };
  
  # Other tools get separate configs
  geminiCli.enable = false;
};

config = {
  # Single config for Claude Desktop + claude-code
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = 
    mkIf cfg.claude.enable (toJSON { mcpServers = cfg.servers; });
  
  # Separate config for gemini-cli with array format conversion
  home.file.".config/gemini-cli/settings.json" = 
    mkIf cfg.geminiCli.enable (toJSON { 
      mcpServers = mapAttrsToList (name: server: server // { type = "stdio"; }) cfg.servers;
    });
};
```

---

## Recommended Implementation Plan

### **Phase 1: Current Focus (Clean Up Existing)**
1. ✅ Remove unused modules (enhanced-servers.nix, multi-tool.nix)
2. ✅ Move server configs from home.nix to module defaults
3. ✅ Simplify home.nix to `home.mcp.enable = true;`
4. ✅ Document current system (Claude Desktop only)

### **Phase 2: Future Enhancement (Multi-Tool Support)**
*Only implement when you actually use these tools*

5. Add `home.mcp.targets` option for tool-specific control
6. Implement gemini-cli config generation (array format)
7. Add project-specific `.mcp.json` support for claude-code
8. Document multi-tool configuration patterns

---

## Current Architecture (Phase 1)

```
modules/home/mcp/
├── default.nix              # Core module with default servers
│   ├── Options:
│   │   ├── enable           # Master switch
│   │   ├── servers          # Server definitions (with defaults)
│   │   └── configPath       # Override config location if needed
│   └── Config:
│       └── Generates: ~/Library/Application Support/Claude/claude_desktop_config.json
│
└── filesystem-server.py     # Custom filesystem server implementation
```

**home.nix:**
```nix
home.mcp.enable = true;  # That's it! Uses sensible defaults.

# Optional: Override specific servers
home.mcp.servers.github.env.GITHUB_TOKEN = "...";  # Add secrets
```

---

## Format Differences: Claude vs Gemini

### Claude Format (Object):
```json
{
  "mcpServers": {
    "github": { "command": "...", "args": [], "env": {} },
    "filesystem": { "command": "...", "args": [] }
  }
}
```

### Gemini Format (Array):
```json
{
  "mcpServers": [
    { "type": "stdio", "command": "...", "args": [], "env": {} },
    { "type": "stdio", "command": "...", "args": [] }
  ]
}
```

**Conversion in Nix:**
```nix
# Claude format (attrset to JSON object)
builtins.toJSON { mcpServers = cfg.servers; }

# Gemini format (attrset to JSON array with type field)
builtins.toJSON { 
  mcpServers = mapAttrsToList 
    (name: server: server // { type = "stdio"; }) 
    cfg.servers;
}
```

---

## Conclusion

**Your vision of a unified MCP config system is absolutely achievable!**

**For Right Now (Phase 1):**
- Keep it simple
- Focus on Claude Desktop (what you're using)
- claude-code will automatically work when you start using it (shared config)

**For Later (Phase 2):**
- Add multi-tool support when needed
- Implement format conversion for gemini-cli
- Add per-tool enabling/disabling

**Key Principle:** YAGNI (You Aren't Gonna Need It) - Don't build multi-tool support until you actually use multiple tools. Start simple, expand when needed.

---

## Next Steps

1. ✅ **Approved Approach:** Hybrid (Phase 1 now, Phase 2 later)
2. ⏭️ Remove unused modules
3. ⏭️ Move configs to module defaults
4. ⏭️ Document simple usage
5. ⏭️ Test and verify

**The groundwork is laid for a beautiful unified system when you need it!**
