# Preference Domain Conflict Audit

**Date:** October 8, 2025  
**Purpose:** Document all preference domain writes across nix-darwin and home-manager modules to identify conflicts

## Executive Summary

This audit identifies which modules write to which macOS preference domains and highlights potential conflicts where multiple modules write to the same domain.

**Key Finding:** The Raycast module was writing directly to `com.apple.symbolichotkeys` without using `mkMerge`, causing it to overwrite the keybindings module's symbolic hotkeys configuration. **This has been fixed.**

## Preference Domain Matrix

### NSGlobalDomain (Global macOS Preferences)

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `darwin/system-defaults` | nix-darwin | Text substitution (NSAutomatic*), panel settings, scrolling, appearance | ✅ Via system.defaults |
| `darwin/fonts` | nix-darwin | AppleFontSmoothing | ✅ Yes (line 116) |
| `darwin/keyboard` | nix-darwin | com.apple.keyboard.fnState | ✅ Via system.defaults |
| `home/macos/keybindings` | home-manager | ApplePressAndHoldEnabled, InitialKeyRepeat, KeyRepeat, AppleKeyboardUIMode | ✅ Via targets.darwin |

**Conflict Status:** ✅ **NO CONFLICTS** - All modules use proper merging or write to non-overlapping keys.

**Separation of Concerns:**
- **nix-darwin modules** manage system-wide text input settings, font smoothing, keyboard hardware settings
- **home-manager keybindings** manages user-level keyboard repeat behavior

### com.apple.symbolichotkeys (Keyboard Shortcuts)

| Module | Layer | Hotkeys Modified | Uses mkMerge? |
|--------|-------|------------------|---------------|
| `home/macos/keybindings` | home-manager | User-defined custom hotkeys | ✅ Yes (line 105) |
| `home/raycast` | home-manager | Hotkey 64 (Spotlight Cmd+Space), Hotkey 65 (Finder search) | ✅ **FIXED** (line 135) |

**Conflict Status:** ✅ **RESOLVED** - Both modules now use `mkMerge` properly.

**Previous Issue:** Raycast module was setting the entire `com.apple.symbolichotkeys` domain directly, overwriting keybindings module's contributions.

### com.raycast.macos (Raycast App Preferences)

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `home/raycast` | home-manager | raycastShouldFollowSystemAppearance, mainWindow_isMonitoringGlobalHotkeys, onboardingCompleted, raycastGlobalHotkey | ✅ Yes (line 110) |

**Conflict Status:** ✅ **NO CONFLICTS** - Single module owns this domain.

### com.bitwarden.desktop (Bitwarden App Preferences)

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `home/security` | home-manager | biometricUnlock, minimizeToTrayOnStart, closeToTray, lockTimeout, security settings | ✅ Via targets.darwin |

**Conflict Status:** ✅ **NO CONFLICTS** - Single module owns this domain.

### com.apple.LaunchServices/com.apple.launchservices.secure

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `home/macos/launchservices` | home-manager | LSHandlers (default applications) | ✅ Via targets.darwin |

**Conflict Status:** ✅ **NO CONFLICTS** - Single module owns this domain.

### com.apple.dock (Dock Configuration)

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `darwin/system-defaults` | nix-darwin | All dock settings (autohide, orientation, persistent apps, hot corners, etc.) | ✅ Via system.defaults |

**Conflict Status:** ✅ **NO CONFLICTS** - Single module owns this domain.

### com.apple.finder (Finder Configuration)

| Module | Layer | Keys Written | Uses mkMerge? |
|--------|-------|--------------|---------------|
| `darwin/system-defaults` | nix-darwin | AppleShowAllExtensions, ShowPathbar, ShowStatusBar, FXPreferredViewStyle | ✅ Via system.defaults |

**Conflict Status:** ✅ **NO CONFLICTS** - Single module owns this domain.

## Conflict Resolution Pattern

The issue causing System Settings corruption was the **symbolic hotkeys conflict**. The pattern that caused it:

### Anti-Pattern (Causes Overwrites)
```nix
targets.darwin.defaults."com.apple.symbolichotkeys" = {
  AppleSymbolicHotKeys = { ... };
};
```

### Correct Pattern (Allows Merging)
```nix
targets.darwin.defaults."com.apple.symbolichotkeys" = mkMerge [
  {
    AppleSymbolicHotKeys = { ... };
  }
];
```

## Best Practices Going Forward

### 1. **Always use mkMerge for shared domains**
When multiple modules might write to the same preference domain, always use `mkMerge`:

```nix
targets.darwin.defaults."com.apple.domain" = mkMerge [
  {
    key1 = value1;
    key2 = value2;
  }
];
```

### 2. **Layer Separation**
- **nix-darwin** (`system.defaults.*`) → System-wide, hardware, and global preferences
- **home-manager** (`targets.darwin.defaults.*`) → User-specific application and behavior preferences

### 3. **Document ownership**
When creating a new module that writes preferences:
- Add a comment explaining which preference domain it writes to
- Note if other modules also write to that domain
- Use `mkMerge` if there's any chance of overlap

### 4. **Avoid duplicating keys**
Never write the same preference key from both nix-darwin and home-manager. This was the original NSGlobalDomain issue documented in `SYSTEM-SETTINGS-FIX.md`.

## Testing Strategy

After making preference domain changes:

1. **Build without applying:** `darwin-rebuild build --flake .`
2. **Inspect generated preferences:** Check the Nix store output
3. **Apply changes:** `darwin-rebuild switch --flake .`
4. **Verify System Settings:** Open System Settings immediately and check that:
   - All panes display correctly
   - No blank/empty screens
   - Settings match your configuration
5. **Test without restart:** Ensure System Settings works correctly without requiring a restart

## Known Working Configuration

As of October 8, 2025, after fixing the symbolic hotkeys conflict:

✅ All modules use proper merging strategies  
✅ No overlapping preference keys between nix-darwin and home-manager  
✅ System Settings displays correctly after rebuild  
✅ No restart required for System Settings to function

## References

- **Fix Details:** `/docs/SYSTEM-SETTINGS-FIX.md` - Original NSGlobalDomain conflict resolution
- **Module Options:** `/docs/module-options.md` - Complete module configuration reference
- **Architecture:** `/docs/architecture.md` - Overall system design principles
