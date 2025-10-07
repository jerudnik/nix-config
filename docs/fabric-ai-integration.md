# Fabric AI Integration

## Overview

Fabric AI has been successfully integrated into your Nix configuration, providing AI-powered productivity patterns for development workflows.

## What is Fabric AI?

Fabric is an open-source framework that augments human productivity using AI. It provides:
- A modular framework for solving specific problems
- A crowdsourced set of AI prompts (patterns)
- CLI tools for piping data through AI models
- YouTube transcript extraction
- Shell integration

## Implementation Details

### Package Source
- **Provider**: nixpkgs (official Home Manager module)
- **Version**: v1.4.308
- **Package**: `fabric-ai`

### Configuration Location

1. **Module**: Nixpkgs built-in `programs.fabric-ai` module
   - No custom wrapper needed
   - Located in Home Manager nixpkgs

2. **Enabled in**: `home/jrudnik/home.nix`
   ```nix
   programs.fabric-ai = {
     enable = true;
     enablePatternsAliases = true;   # Shell aliases for all patterns
     enableYtAlias = true;            # YouTube transcript helper
   };
   ```

3. **Custom Patterns**: `modules/home/ai/patterns/fabric/tasks/`
   - Linked via `xdg.configFile."fabric/patterns"`
   - Merged with official Fabric patterns

### Features Enabled

✅ **Shell Integration**
- Pattern aliases auto-generated in zsh
- `yt` command for YouTube transcripts
- Seamless piping of data through patterns

✅ **Custom Patterns** (7 patterns)
- `code-to-docs` - Generate technical documentation from source code
- `daily-notes` - Create structured daily work notes
- `decision-log` - Document important project decisions
- `generate-adr` - Create Architecture Decision Records
- `postmortem` - Create incident post-mortems
- `refactor-plan` - Generate refactoring plans
- `summarize-pr` - Summarize pull requests

✅ **Official Patterns** (226 patterns)
- Downloaded from https://github.com/danielmiessler/fabric
- Automatically updated via `fabric --update`

## Directory Structure

```
modules/home/ai/
├── patterns/
│   └── fabric/
│       ├── README.md           # Documentation
│       └── tasks/              # Custom patterns
│           ├── code-to-docs.md
│           ├── daily-notes.md
│           ├── decision-log.md
│           ├── generate-adr.md
│           ├── postmortem.md
│           ├── refactor-plan.md
│           └── summarize-pr.md
└── interfaces/
    └── default.nix             # Imports (fabric-ai via nixpkgs)
```

## Usage Examples

### Basic Usage
```bash
# List all patterns (official + custom)
fabric --listpatterns

# Use a custom pattern
cat some-code.nix | fabric --pattern code-to-docs

# Create a decision log
echo "We decided to use mcp-servers-nix because..." | fabric --pattern decision-log

# Generate an ADR
echo "Decision about MCP architecture..." | fabric --pattern generate-adr
```

### YouTube Transcripts
```bash
# Get transcript
yt https://youtube.com/watch?v=...

# Get transcript with timestamps
yt -t https://youtube.com/watch?v=...

# Process transcript through a pattern
yt https://youtube.com/... | fabric --pattern summarize
```

### With Shell Aliases (if enablePatternsAliases = true)
```bash
# Each pattern gets an alias
echo "Some code" | code-to-docs
echo "Decision context" | decision-log
echo "Issue description" | generate-adr
```

## Configuration Files

Fabric stores its configuration in:
- `~/.config/fabric/` - Main configuration directory
- `~/.config/fabric/.env` - API keys and settings
- `~/.config/fabric/patterns/` - All patterns (official + custom)
- `~/.config/fabric/strategies/` - Prompting strategies

## Initial Setup (Already Completed)

During setup, the following was configured:
1. ✅ Anthropic Claude integration (OAuth)
2. ✅ Default model: `claude-sonnet-4-20250514`
3. ✅ Downloaded official patterns (226 patterns)
4. ✅ Downloaded prompting strategies
5. ✅ Custom patterns linked automatically

## API Key Management

Fabric API keys are stored in `~/.config/fabric/.env` and can be managed via:

```bash
# View current configuration
cat ~/.config/fabric/.env

# Reconfigure vendors/models
fabric --setup
```

For security, consider using your AI secrets management system:
```bash
# Store API key in macOS Keychain
ai-add-secret ANTHROPIC_API_KEY "sk-ant-..."

# Fabric reads from .env, so you'd manually sync or use env vars
export ANTHROPIC_API_KEY=$(security find-generic-password -a "$USER" -s "ANTHROPIC_API_KEY" -w)
```

## Adding New Custom Patterns

1. Create a new `.md` file in `modules/home/ai/patterns/fabric/tasks/`
2. Follow the standard Fabric pattern format:
   ```markdown
   # IDENTITY and PURPOSE
   [Role and purpose]
   
   # STEPS
   - [Step 1]
   - [Step 2]
   
   # OUTPUT
   [Expected format]
   
   # INPUT
   [Input description]
   ```
3. Rebuild system: `darwin-rebuild switch --flake ~/nix-config#parsley`
4. Pattern is automatically available

## Maintenance

### Update Patterns
```bash
# Update official patterns
fabric --update

# Update strategies
fabric --updatestrategies
```

### Reconfigure
```bash
# Interactive setup
fabric --setup

# Configure specific vendor
fabric --setup-vendor anthropic
```

### Troubleshooting
```bash
# Check configuration
fabric --listmodels

# Verify patterns are loaded
fabric --listpatterns

# Check for custom patterns
ls ~/.config/fabric/patterns/ | grep -E "(code-to-docs|daily-notes|decision-log)"
```

## Architecture Decisions

### Why Use Nixpkgs Module Instead of Custom?

**Decision**: Use the official nixpkgs `programs.fabric-ai` module

**Rationale**:
1. ✅ Maintained by Home Manager community
2. ✅ Automatic updates with nixpkgs
3. ✅ Battle-tested shell integration
4. ✅ Standard interface (mkEnableOption, etc.)
5. ✅ No custom code to maintain

**Trade-off**: The nixpkgs module doesn't directly support customPatterns option, but we work around this by using `xdg.configFile` to link our custom patterns.

### Why Move Patterns to modules/home/ai/?

**Decision**: Move from `config/fabric/` to `modules/home/ai/patterns/fabric/`

**Rationale**:
1. ✅ Co-located with AI modules that use them
2. ✅ Clear these are AI-specific patterns
3. ✅ More maintainable relative paths
4. ✅ Discoverable by future maintainers
5. ✅ Room to grow (other pattern types)

## Integration with Other Tools

Fabric works well with other AI tools in your configuration:

- **code2prompt** → Fabric: Convert code to prompt, pipe through pattern
- **files-to-prompt** → Fabric: Bundle files, pipe through pattern
- **Claude Desktop/Code**: Can reference Fabric pattern outputs
- **GitHub Copilot CLI**: Complementary - Copilot for code, Fabric for workflows

## Resources

- **Official Site**: https://github.com/danielmiessler/fabric
- **Pattern Library**: https://github.com/danielmiessler/fabric/tree/main/patterns
- **Documentation**: https://github.com/danielmiessler/fabric/wiki
- **Home Manager Module**: Search "fabric-ai" in Home Manager options

## Status

✅ **Fully Integrated and Operational**
- Package installed via nixpkgs
- Custom patterns linked and available
- Shell integration enabled
- API configured (Anthropic Claude)
- Ready for daily use

## Next Steps

Consider:
1. Creating project-specific patterns (e.g., nix-specific documentation)
2. Integrating with git hooks for commit message generation
3. Using with `yt` for summarizing technical talks
4. Creating patterns for code review feedback
