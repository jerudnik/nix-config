# Documentation Archive

This directory contains historical documentation that provided value during specific phases of the project but is no longer part of the active documentation set. These files are preserved for reference and to maintain a complete project history.

## Archive Organization

### `audits/` - Compliance & Structure Audits

Comprehensive audits performed at various stages of the project to ensure WARP.md compliance and identify technical debt.

**Files:**
- `DOCUMENTATION-AUDIT.md` - Documentation accuracy audit (Oct 2025)
- `warp-compliance-audit.md` - WARP.md law compliance verification
- `mcp-ai-structure-analysis.md` - MCP integration structural analysis
- `ai-module-structure-analysis.md` - AI module organization review
- `preference-domain-audit.md` - macOS preference domain conflict analysis
- `PHASE2-AUDIT.md` - Phase 2 refactoring audit

**Outcome:** All findings addressed and incorporated into active documentation.

### `research/` - Research & Evaluation Documents

In-depth research conducted to evaluate technical approaches and solutions before implementation.

**Files:**
- `mcp-config-research.md` - Multi-tool MCP configuration research
- `mcp-servers-nix-evaluation.md` - Evaluation of mcp-servers-nix adoption

**Outcome:** Findings guided implementation decisions, now documented in `docs/mcp.md`.

### `migrations/` - Migration & Cleanup After-Action Reports

Detailed post-migration analyses documenting what changed, why, and lessons learned.

#### `migrations/ai-module/`
- `ai-module-cleanup-complete.md` - AI module structure cleanup and consolidation

**Outcome:** Module structure optimized, documentation in `docs/ai-tools.md`.

#### `migrations/mcp/`
- `mcp-migration-complete.md` - Migration from custom MCP to mcp-servers-nix

**Outcome:** Successfully migrated, documented in `docs/mcp.md` with migration history section.

#### `migrations/system-settings/`
- `system-settings-permanent-fix.md` - Comprehensive system-settings fix implementation
- `SYSTEM-SETTINGS-FIX.md` - Original NSGlobalDomain conflict analysis
- `raycast-removal.md` - Raycast module removal documentation

**Outcome:** All learnings consolidated into `docs/darwin-modules-conflicts.md`.

## Why Archive?

These documents served important purposes at the time of writing:

1. **Audits** identified technical debt and compliance violations
2. **Research** guided architectural decisions
3. **Migrations** documented transition processes and lessons learned

However, their **findings and valuable insights have been incorporated** into the active documentation:

- **`docs/darwin-modules-conflicts.md`** - System-settings architecture and migration timeline
- **`docs/mcp.md`** - MCP integration with historical context
- **`docs/ai-tools.md`** - AI module structure
- **`docs/COMPLIANCE-SUMMARY.md`** - Current WARP.md compliance status
- **`WARP.md`** - Updated with system-settings domain authority rules

## When to Reference Archive

Consult archived documents when you need:

- **Historical context** on why specific architectural decisions were made
- **Migration details** if reverting or reimplementing similar changes
- **Audit methodologies** for conducting future compliance reviews
- **Research findings** for evaluating alternative approaches

## Active Documentation

For current, maintained documentation, see:

- **`docs/`** - All active documentation
- **`docs/darwin-modules-conflicts.md`** - System Settings architecture (includes migration timeline)
- **`docs/mcp.md`** - Current MCP integration guide
- **`docs/ai-tools.md`** - Current AI tools setup
- **`WARP.md`** - Mandatory configuration rules

---

**Archive Created:** October 2025  
**Archival Policy:** Documents are archived when their findings are fully incorporated into active documentation  
**Retention:** Permanent - maintained for historical reference
