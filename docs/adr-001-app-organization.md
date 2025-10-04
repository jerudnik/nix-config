# ADR-001: macOS App Organization and Launcher Integration

**Status**: Accepted  
**Date**: 2025-01-04  
**Decision Makers**: jrudnik  

## Context

The nix-darwin and Home Manager setup was creating duplicate and confusing app folders due to custom spotlight module configuration. Multiple symlinked folders existed:

- `~/Applications/home-manager` (custom spotlight module)
- `~/Applications/Home Manager Apps` (Home Manager default)
- `~/Applications/nix-darwin` (custom spotlight module)
- `~/Applications/nix-darwin` (nix-darwin default: `/Applications/Nix Apps`)
- Direct nix symlinks in `/Applications/` root

This caused confusion about where apps were located and required complex Spotlight reindexing logic.

## Decision

**Adopt the standard two-folder model using official tool defaults:**

1. **Home Manager apps**: `~/Applications/Home Manager Apps/` (official HM default)
2. **System apps**: `/Applications/Nix Apps/` (official nix-darwin default)
3. **Remove custom spotlight module** entirely
4. **Use Raycast for app launching** (no Spotlight integration needed)

## Rationale

### Why This Approach:

1. **Follows Official Defaults**: Both tools have sensible defaults that work out of the box
2. **Zero Configuration Needed**: No custom overrides or complex module logic required
3. **Clean Separation**: User vs system apps clearly separated
4. **Raycast Integration**: Raycast automatically discovers apps in standard locations
5. **Community Standard**: Aligns with 2024 best practices from nix community
6. **Maintainable**: Reduces custom code and configuration complexity

### Alternative Considered:

- **Single unified folder**: Would require overriding both tool defaults
- **Direct `/Applications` linking**: Clutters system folder with nix symlinks
- **Keep custom spotlight module**: Unnecessary complexity since using Raycast

## Implementation

### Changes Made:

1. **Removed custom spotlight module** (`modules/home/spotlight/`)
2. **Disabled spotlight configuration** in `home/jrudnik/home.nix`
3. **Cleaned up duplicate folders**:
   - Removed `~/Applications/home-manager`
   - Removed `~/Applications/nix-darwin`
   - Removed `~/Applications/Nix` and `~/Applications/NixSystem`
   - Removed direct nix symlinks from `/Applications/`
4. **Relied on defaults**:
   - Home Manager creates `~/Applications/Home Manager Apps/`
   - nix-darwin creates `/Applications/Nix Apps/`

### Current App Locations:

- **Home Manager Apps** (`~/Applications/Home Manager Apps/`):
  - AeroSpace.app (window manager)
  - Alacritty.app (terminal)
  - Emacs.app (editor)
  - Raycast.app (launcher)

- **System Apps** (`/Applications/Nix Apps/`):
  - Warp.app (terminal from nixpkgs `warp-terminal`)

## Consequences

### Positive:

- ✅ **Simplified configuration**: No custom app linking logic needed
- ✅ **Standard behavior**: Predictable locations that follow tool conventions
- ✅ **Easy maintenance**: Fewer custom modules to maintain
- ✅ **Raycast integration**: Apps automatically discoverable
- ✅ **Clean filesystem**: No duplicate or confusing folders

### Negative:

- ❌ **Folder names with spaces**: `Home Manager Apps` has spaces (minor aesthetic issue)
- ❌ **No Spotlight shortcuts**: Removed mdutil aliases (acceptable since using Raycast)

### Neutral:

- 🔄 **App installation flow unchanged**: Apps still appear automatically when packages are added
- 🔄 **Backup integration unchanged**: Both folders are in user space or system space appropriately

## Rollback Plan

If needed, rollback by:

1. Re-adding the spotlight module from git history
2. Re-importing it in `modules/home/default.nix`
3. Re-enabling it in `home/jrudnik/home.nix`
4. Running `darwin-rebuild switch`

However, this decision aligns with best practices and simplifies the setup significantly.

## References

- [Home Manager Manual - macOS Integration](https://home-manager.dev/manual/24.11/)
- [nix-darwin Repository - Application Handling](https://github.com/nix-darwin/nix-darwin)
- Community research on nix-darwin + Home Manager app organization (2024)
- [Raycast Documentation - App Discovery](https://raycast.com/docs)