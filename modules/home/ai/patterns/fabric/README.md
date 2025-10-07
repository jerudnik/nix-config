# Fabric AI Patterns

This directory contains custom Fabric AI patterns (prompts) for productivity and development workflows.

## Directory Structure

- `tasks/` - Custom task patterns for Fabric AI

## What are Fabric Patterns?

Fabric patterns are structured prompts that guide AI models to perform specific tasks consistently. Each pattern is a markdown file with:

- **IDENTITY and PURPOSE**: Defines the AI's role and task
- **STEPS**: Describes the process to follow
- **OUTPUT**: Specifies the expected output format
- **INPUT**: Describes what input the pattern expects

## Custom Patterns in `tasks/`

These are custom patterns specific to your workflow:

| Pattern | Purpose |
|---------|---------|
| `code-to-docs.md` | Generate technical documentation from source code |
| `daily-notes.md` | Create structured daily work notes |
| `decision-log.md` | Document important project decisions |
| `generate-adr.md` | Create Architecture Decision Records (ADRs) |
| `postmortem.md` | Create incident post-mortems |
| `refactor-plan.md` | Generate refactoring plans |
| `summarize-pr.md` | Summarize pull requests |

## How Patterns are Used

These patterns are automatically linked to `~/.config/fabric/patterns/` via Home Manager configuration (see `home/jrudnik/home.nix`).

Fabric merges:
1. **Official patterns** - Downloaded from https://github.com/danielmiessler/fabric
2. **Your custom patterns** - From this directory

## Usage Examples

```bash
# List all available patterns (including custom ones)
fabric --listpatterns

# List only custom patterns (via shell alias)
alias | grep fabric

# Use a custom pattern
cat my-code.nix | fabric --pattern code-to-docs

# Create a decision log
echo "We decided to use mcp-servers-nix because..." | fabric --pattern decision-log

# Generate an ADR
echo "Decision about MCP architecture..." | fabric --pattern generate-adr
```

## Adding New Patterns

1. Create a new `.md` file in `tasks/`
2. Follow the standard Fabric pattern format (see existing patterns)
3. Rebuild your system: `darwin-rebuild switch --flake ~/nix-config#parsley`
4. The pattern will be automatically available in Fabric

## Pattern Format Template

```markdown
# IDENTITY and PURPOSE

[Describe the AI's role and the task's purpose]

# STEPS

- [Step 1]
- [Step 2]
- [etc.]

# OUTPUT

[Describe the expected output format]

# INPUT

[Describe what input this pattern expects]
```

## Official Patterns

Fabric also includes 200+ official patterns from the community. View them:
- Online: https://github.com/danielmiessler/fabric/tree/main/patterns
- Locally: `~/.config/fabric/patterns/`

## Integration

This patterns directory is integrated into your Nix configuration via:

1. **Module**: `modules/home/ai/interfaces/` imports nixpkgs `fabric-ai` module
2. **Configuration**: `home/jrudnik/home.nix` enables Fabric with shell integration
3. **Patterns**: This directory is linked via `xdg.configFile."fabric/patterns"`

## Resources

- [Fabric GitHub](https://github.com/danielmiessler/fabric)
- [Fabric Documentation](https://github.com/danielmiessler/fabric/wiki)
- [Pattern Examples](https://github.com/danielmiessler/fabric/tree/main/patterns)
