# System Settings Migration Archive

Documentation of the system-settings architecture fix and NSGlobalDomain conflict resolution completed in October 2025.

## Files

### `system-settings-permanent-fix.md`
**Date:** October 2025  
**Status:** ✅ Complete

Comprehensive fix implementation document covering:
- Problem analysis (NSGlobalDomain conflicts)
- Multi-layered solution approach
- Detailed change documentation
- Testing and validation procedures
- Rollback plan

### `SYSTEM-SETTINGS-FIX.md`
**Date:** October 2025  
**Status:** ✅ Complete

Original problem analysis and initial separation of concerns:
- NSGlobalDomain conflict identification
- Boundary definition (nix-darwin vs home-manager)
- Initial resolution approach
- Cleanup procedures

### `raycast-removal.md`
**Date:** October 2025  
**Status:** ✅ Complete

Documentation of Raycast module removal:
- Raycast as contributor to symbolic hotkeys conflicts
- Complete removal process
- Spotlight re-enablement
- Alternative launcher options

## Problem Summary

**Symptoms:**
- System Settings displayed blank panes after `darwin-rebuild switch`
- Keyboard settings pane particularly affected
- Required restart to view settings
- Intermittent preference corruption

**Root Causes:**
1. Multiple modules writing to `NSGlobalDomain` (darwin/keyboard + darwin/system-defaults)
2. No coordination between nix-darwin and home-manager writes
3. cfprefsd cache corruption from conflicting data
4. No validation of preference files
5. Raycast module overwriting symbolic hotkeys

## Solution Architecture

**Multi-Layered Approach:**

### 1. Single Source of Truth
- Moved ALL NSGlobalDomain writes to nix-darwin only
- Created unified `system-settings` module
- Organized by System Settings panes (Keyboard, Dock, Appearance, etc.)

### 2. Pane-Based Organization
```
darwin.system-settings/
├── keyboard.nix           # System Settings > Keyboard
├── desktop-and-dock.nix   # System Settings > Desktop & Dock
├── appearance.nix         # System Settings > Appearance
├── trackpad.nix           # System Settings > Trackpad
└── general.nix            # System Settings > General
```

### 3. Unified Config Block
Single coordinated NSGlobalDomain write in `default.nix` to prevent conflicts.

### 4. Cache Management
Critical activation scripts:
```nix
# Kill cfprefsd to force cache flush
/usr/bin/killall cfprefsd 2>/dev/null || true

# Force macOS to reload preferences without logout
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

### 5. Validation
Preference file integrity checking after activation.

## Implementation Highlights

**Merged keyboard module:**
- Moved all keyboard settings from separate module into system-settings/keyboard.nix
- Consolidated NSGlobalDomain writes
- Added proper assertions for conflicting settings
- Removed standalone darwin/keyboard module

**Cleaned up home-manager:**
- Removed NSGlobalDomain writes from home/macos/keybindings
- Kept symbolic hotkeys (user-specific)
- Established clear boundaries

**Resolved Raycast conflict:**
- Fixed symbolic hotkeys overwriting
- Eventually removed Raycast module entirely
- Documented alternative launcher options

## Results

**Successful Resolution:**
- ✅ System Settings displays correctly after rebuild
- ✅ No blank panes
- ✅ Settings apply immediately without restart
- ✅ No preference corruption
- ✅ Future rebuilds work correctly
- ✅ Clear architectural guidelines established

**Code Quality:**
- Single source of truth for NSGlobalDomain
- Intuitive pane-based organization
- Proper cache synchronization
- Validation built-in

## Key Learnings

### Architectural Principles
1. **Single source of truth** - One module owns each preference domain
2. **Pane-based organization** - Mirror macOS UI for intuitive configuration
3. **Unified config block** - Coordinated writes prevent conflicts
4. **Cache management** - Must synchronize cfprefsd after writes
5. **Layer separation** - nix-darwin for system, home-manager for user

### Technical Insights
1. **cfprefsd caching** - macOS caches preferences, must kill and restart
2. **activateSettings** - Forces reload without logout
3. **Preference validation** - Detect corruption early with plutil
4. **Never duplicate keys** - Between nix-darwin and home-manager

### Migration Best Practices
1. **Audit first** - Identify all preference domain writes
2. **Plan architecture** - Design before implementing
3. **Implement in phases** - Test between changes
4. **Validate thoroughly** - Check System Settings immediately
5. **Document decisions** - Capture rationale and guidelines

## Current Documentation

All learnings consolidated into:
- **`docs/darwin-modules-conflicts.md`** - Complete analysis with migration timeline
- **`WARP.md`** - LAW 5.4 documents system-settings domain authority
- **`docs/module-options.md`** - system-settings options reference

## When to Reference

Consult these migration documents when:
- Troubleshooting System Settings blank panes
- Adding new macOS system preferences
- Understanding system-settings architecture
- Learning about preference domain conflicts
- Making similar architectural decisions

## Related Archives

- **`audits/preference-domain-audit.md`** - Complete audit of all preference domains
- **`audits/DOCUMENTATION-AUDIT.md`** - Documentation gaps that needed fixing

---

**Migration Status:** ✅ Complete  
**Problem:** Resolved  
**Architecture:** Stable and production-ready  
**Guidelines:** Established and documented
