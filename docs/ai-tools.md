# AI Tools Integration

Complete guide to AI tools in this nix-config: Claude Desktop, Claude Code CLI, Gemini CLI, GitHub Copilot, and Fabric AI.

**Status**: ✅ Production-ready  
**Last Updated**: 2025-10-07

---

## Overview

This configuration provides a comprehensive AI development environment with:

- **Claude Desktop** (Homebrew cask) + MCP servers
- **Claude Code CLI** (nixpkgs)
- **Gemini CLI** (nixpkgs)
- **GitHub Copilot CLI** (nixpkgs)
- **Fabric AI** (nixpkgs) + custom patterns
- **code2prompt** & **files-to-prompt** (nixpkgs)

All tools use **nixpkgs-first** approach per WARP.md rules, with documented exceptions.

---

## Module Structure

```
modules/home/ai/
├── code-analysis/              # Code → prompt conversion
│   ├── code2prompt.nix        # Single file → prompt
│   ├── files-to-prompt.nix    # Multiple files → prompt
│   └── default.nix
├── infrastructure/             # Supporting systems
│   ├── secrets.nix            # macOS Keychain integration
│   └── default.nix
├── interfaces/                 # Direct LLM interaction
│   ├── claude-desktop.nix     # (disabled - using Homebrew)
│   ├── copilot-cli.nix        # GitHub Copilot wrapper
│   ├── goose-cli.nix          # Goose AI (disabled)
│   └── default.nix
├── patterns/fabric/            # Fabric AI patterns
│   ├── tasks/                 # Custom patterns (7 total)
│   └── README.md
├── utilities/                  # Helper tools
│   ├── diagnostics.nix        # AI tools diagnostics
│   └── default.nix
└── default.nix                # Main AI module aggregator
```

---

## Enabled Tools

### Claude Desktop (Homebrew)

**Why Homebrew**: Not available in nixpkgs (as of 2025-10-06)

**Configuration**:
- Installed via: `homebrew.casks = [ "claude" ];`
- MCP config via: `home.file."Library/Application Support/Claude/claude_desktop_config.json"`
- MCP servers: mcp-servers-nix (filesystem, github, git, time, fetch)

**See**: `docs/mcp.md` for MCP server details

### Claude Code CLI (nixpkgs)

**Package**: `programs.claude-code.enable = true;`  
**Purpose**: Terminal-based Claude interaction  
**Status**: ✅ Working via nixpkgs module

```bash
# Usage
claude-code "Explain this code"
cat file.nix | claude-code "Document this"
```

### Gemini CLI (nixpkgs)

**Package**: `programs.gemini-cli.enable = true;`  
**Purpose**: Google Gemini terminal interface  
**Status**: ✅ Working via nixpkgs module

```bash
# Usage  
gemini "Explain quantum computing"
cat code.py | gemini "Review this code"
```

### GitHub Copilot CLI (nixpkgs)

**Package**: `programs.github-copilot-cli.enable = true;`  
**Purpose**: GitHub Copilot terminal suggestions  
**Status**: ✅ Working via nixpkgs module

```bash
# Usage
gh copilot suggest "git command to undo last commit"
gh copilot explain "docker run -p 8080:80 nginx"
```

### Fabric AI (nixpkgs)

**Package**: `programs.fabric-ai.enable = true;`  
**Purpose**: AI productivity patterns  
**Custom Patterns**: 7 patterns in `modules/home/ai/patterns/fabric/tasks/`

**Configuration**:
```nix
programs.fabric-ai = {
  enable = true;
  enablePatternsAliases = true;   # Shell aliases for patterns
  enableYtAlias = true;            # YouTube transcript helper
};
```

**Custom Patterns**:
1. `code-to-docs` - Generate documentation from code
2. `daily-notes` - Structured daily notes
3. `decision-log` - Document decisions
4. `generate-adr` - Create ADRs
5. `postmortem` - Incident analysis
6. `refactor-plan` - Refactoring guidance
7. `summarize-pr` - Pull request summaries

**See**: `docs/fabric-ai-integration.md` for detailed Fabric guide

### Code Analysis Tools (nixpkgs)

**code2prompt**: Convert single file to LLM prompt  
**files-to-prompt**: Convert multiple files to LLM prompt

```bash
# Single file
code2prompt file.nix > prompt.txt

# Multiple files
files-to-prompt src/ --extensions .nix .md > prompt.txt
```

---

## Secret Management

### macOS Keychain Integration

AI API keys stored securely in macOS Keychain via custom module.

**Module**: `modules/home/ai/infrastructure/secrets.nix`

**Configuration**:
```nix
programs.ai.secrets = {
  enable = true;
  shellIntegration = true;  # Auto-source in shell
};
```

**Commands**:
```bash
# Add secret
ai-add-secret ANTHROPIC_API_KEY "sk-ant-..."

# List secrets
ai-list-secrets

# Remove secret
ai-remove-secret ANTHROPIC_API_KEY

# Check diagnostics
ai-check-diagnostics
```

**Secrets are**:
- Stored in macOS Keychain (secure)
- Auto-sourced in shell sessions
- Never hardcoded in configuration
- Easily rotated/updated

---

## Diagnostics

### AI Tools Diagnostics Module

**Module**: `programs.ai.diagnostics.enable = true;`

Provides `ai-check-diagnostics` command to verify AI tools status:

```bash
ai-check-diagnostics

# Output:
✅ Claude Code: Installed
✅ Gemini CLI: Installed  
✅ GitHub Copilot: Installed
✅ Fabric AI: Installed (v1.4.308)
✅ code2prompt: Installed
✅ files-to-prompt: Installed
✅ MCP Config: Valid JSON
✅ Secrets: 3 keys configured
```

---

## Usage Examples

### Workflow: Code Documentation

```bash
# 1. Convert code to prompt
code2prompt mymodule.nix > prompt.txt

# 2. Generate docs with Fabric
cat prompt.txt | fabric --pattern code-to-docs > docs.md

# 3. Review with Claude
cat docs.md | claude-code "Review this documentation"
```

### Workflow: PR Summary

```bash
# 1. Get PR diff
gh pr diff 123 > pr.diff

# 2. Summarize with Fabric
cat pr.diff | fabric --pattern summarize-pr > summary.md

# 3. Post as comment
gh pr comment 123 --body-file summary.md
```

### Workflow: Decision Documentation

```bash
# 1. Create decision log
echo "We chose mcp-servers-nix because..." | fabric --pattern decision-log > decision.md

# 2. Generate ADR
cat decision.md | fabric --pattern generate-adr > adrs/001-mcp-servers.md

# 3. Commit
git add adrs/ && git commit -m "docs: Add MCP decision ADR"
```

---

## WARP.md Compliance

### Nixpkgs-First Adherence ✅

| Tool | Source | Compliance |
|------|--------|------------|
| Claude Code | nixpkgs | ✅ Compliant |
| Gemini CLI | nixpkgs | ✅ Compliant |
| GitHub Copilot | nixpkgs | ✅ Compliant |
| Fabric AI | nixpkgs | ✅ Compliant |
| code2prompt | nixpkgs | ✅ Compliant |
| files-to-prompt | nixpkgs | ✅ Compliant |
| Claude Desktop | Homebrew | ✅ Exception documented |

### Exception: Claude Desktop

**Status**: Documented in `docs/exceptions.md`

**Justification**:
- Not available in nixpkgs
- Official Anthropic distribution via Homebrew only
- Frequently updated Electron app
- No community packaging effort
- MCP servers still use nixpkgs (mcp-servers-nix)

### No Custom Wrapper Modules ✅

Per RULE 2.4, all nixpkgs programs used directly:
- ❌ **Deleted**: Custom `claude-code.nix` wrapper
- ❌ **Deleted**: Custom `gemini-cli.nix` wrapper
- ✅ **Direct**: `programs.claude-code.enable = true;`
- ✅ **Direct**: `programs.gemini-cli.enable = true;`

---

## Future Enhancements

**Potential additions**:
- Cursor AI editor (if becomes available in nixpkgs)
- Continue.dev (VS Code extension coordination)
- Local LLM integration (Ollama via nixpkgs)
- Additional Fabric patterns for nix-specific workflows

**Adding new tools**: Follow WARP.md RULE 5.1 - check nixpkgs first!

---

## Troubleshooting

### Tool Not Found

```bash
# Verify installation
which claude-code
which gemini-cli
which fabric

# Check PATH
echo $PATH | tr ':' '\n' | grep per-user

# Reload shell
exec zsh
```

### API Key Issues

```bash
# Check secrets
ai-list-secrets

# Test secret retrieval
security find-generic-password -a "$USER" -s "ANTHROPIC_API_KEY" -w

# Re-add if needed
ai-remove-secret ANTHROPIC_API_KEY
ai-add-secret ANTHROPIC_API_KEY "new-key"
```

### Fabric Patterns Not Found

```bash
# Check patterns directory
ls ~/.config/fabric/patterns/

# Verify custom patterns linked
ls -la ~/.config/fabric/patterns/ | grep code-to-docs

# Rebuild if needed
darwin-rebuild switch --flake ~/nix-config#parsley
```

---

## Resources

- **Fabric AI**: https://github.com/danielmiessler/fabric
- **MCP Integration**: `docs/mcp.md`
- **Secret Management**: `modules/home/ai/infrastructure/secrets.nix`
- **Pattern Documentation**: `modules/home/ai/patterns/fabric/README.md`
- **Exceptions**: `docs/exceptions.md`
