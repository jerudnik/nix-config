# Migrations Archive

This directory contains detailed after-action reports for significant migrations and cleanup operations. Each document captures what changed, why, lessons learned, and outcomes.

## Directory Structure

### `ai-module/` - AI Module Structure Cleanup
Cleanup and consolidation of AI module structure, eliminating orphaned code and redundancies.

### `mcp/` - MCP Integration Migration
Migration from custom MCP implementation to upstream mcp-servers-nix solution.

### `system-settings/` - System Settings Architecture Fix
Resolution of NSGlobalDomain conflicts and migration to unified system-settings architecture.

## Migration Philosophy

Each migration followed a consistent pattern:

1. **Problem Identification** - What issue prompted the migration?
2. **Analysis** - Deep dive into root causes
3. **Solution Design** - Architectural approach to resolution
4. **Implementation** - Step-by-step execution
5. **Validation** - Testing and verification
6. **Documentation** - Capture learnings for future

## Value of Migration Documentation

These after-action reports provide:

- **Historical Context** - Why changes were made
- **Decision Rationale** - What alternatives were considered
- **Implementation Details** - How changes were executed
- **Lessons Learned** - What worked, what didn't
- **Future Guidance** - How to handle similar situations

## Current Status

All migrations are **complete and successful**:

- ✅ AI modules cleaned up and optimized
- ✅ MCP integration migrated to mcp-servers-nix
- ✅ System Settings conflicts resolved

Key learnings have been incorporated into:

- **`docs/darwin-modules-conflicts.md`** - System Settings architecture and timeline
- **`docs/mcp.md`** - MCP integration with migration history
- **`docs/ai-tools.md`** - Current AI module structure
- **`WARP.md`** - Updated rules based on learnings

## When to Reference

Consult these migration documents when:

- **Considering similar migrations** - Learn from past approaches
- **Reverting changes** - Understand what was changed and why
- **Troubleshooting** - Historical context for current architecture
- **Training** - Teaching others about the project's evolution
- **Decision-making** - Reference past decisions and outcomes

## Related Archives

- **`audits/`** - Audits that identified migration needs
- **`research/`** - Research that informed migration approaches

---

**Archive Status:** Complete  
**All Migrations:** Successful  
**Reference Value:** High for understanding project evolution and decision-making
