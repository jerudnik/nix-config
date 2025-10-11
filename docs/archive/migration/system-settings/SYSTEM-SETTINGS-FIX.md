# System Settings Fix - NSGlobalDomain Conflict Resolution

**Issue Date:** October 8, 2025  
**Branch:** `fix-nsglobaldomain-conflict`  
**Status:** ✅ Code fixed, requires cleanup and activation

## Problem Summary

macOS System Settings was displaying empty panes and missing options after enabling the `home.macos.keybindings` module. This was caused by **conflicting NSGlobalDomain preference writes** from both nix-darwin and home-manager.

### Root Cause

Both configuration layers were writing to the same `NSGlobalDomain` keys:
- **nix-darwin** (`modules/darwin/system-defaults/default.nix`) was setting text substitution preferences
- **home-manager** (`modules/home/macos/keybindings.nix`) was duplicating the same text substitution keys

When both try to manage the same preference domain, macOS gets confused and System Settings becomes corrupted.

## The Fix Applied

### Changes Made

1. **Removed duplicate settings from home-manager** (`modules/home/macos/keybindings.nix`):
   - Removed: `NSAutomaticCapitalizationEnabled`
   - Removed: `NSAutomaticDashSubstitutionEnabled`
   - Removed: `NSAutomaticPeriodSubstitutionEnabled`
   - Removed: `NSAutomaticQuoteSubstitutionEnabled`
   - Removed: `NSAutomaticSpellingCorrectionEnabled`
   - Kept: Keyboard-specific settings (key repeat, press-and-hold, keyboard UI mode)

2. **Added documentation comments** to both modules explaining the boundary:
   - nix-darwin owns: Text substitution and system-wide text input settings
   - home-manager owns: Keyboard behavior and user-specific keyboard preferences

### Architecture Decision

**Separation of Concerns:**
- **System-level preferences** → `nix-darwin` (`system.defaults.NSGlobalDomain`)
- **User-level preferences** → `home-manager` (`targets.darwin.defaults.NSGlobalDomain`)
- **Never duplicate keys** between the two layers

## Next Steps - Manual Cleanup Required

⚠️ **IMPORTANT:** The corrupted preference files must be cleaned up before the fix takes full effect.

### Step 1: Close System Settings

If System Settings is open, close it completely:
```bash
killall "System Settings" 2>/dev/null || true
```

### Step 2: Reset Preference Cache

Kill the preference daemon to clear caches:
```bash
killall cfprefsd
sudo killall cfprefsd
```

### Step 3: Back Up and Remove Corrupted Plists

Back up current GlobalPreferences and remove them so the activation can write clean state:

```bash
# Back up user preferences (if they exist)
if [ -f ~/Library/Preferences/.GlobalPreferences.plist ]; then
  cp ~/Library/Preferences/.GlobalPreferences.plist \
     ~/Library/Preferences/.GlobalPreferences.plist.bak.$(date +%s)
fi

# Remove potentially corrupted user ByHost variants
rm -f ~/Library/Preferences/ByHost/.GlobalPreferences.*.plist

# Back up system preferences (if they exist and you have permissions)
if [ -f /Library/Preferences/.GlobalPreferences.plist ]; then
  sudo cp /Library/Preferences/.GlobalPreferences.plist \
          /Library/Preferences/.GlobalPreferences.plist.bak.$(date +%s)
fi
```

**Note:** Removing these files will reset some UI preferences temporarily. The nix-config will re-apply the desired settings on activation.

### Step 4: Apply the Fixed Configuration

Now rebuild with the fixed configuration:
```bash
cd ~/nix-config
./scripts/build.sh switch
```

This will:
- Apply the corrected NSGlobalDomain settings
- Restart Dock and Finder
- Relaunch cfprefsd automatically

### Step 5: Verify System Settings

1. **Open System Settings:**
   ```bash
   open "/System/Applications/System Settings.app"
   ```

2. **Check that all panes are visible** in the left sidebar

3. **Verify preferences are applied:**
   ```bash
   # Keyboard settings (should show values)
   defaults read -g ApplePressAndHoldEnabled
   defaults read -g InitialKeyRepeat
   defaults read -g KeyRepeat
   defaults read -g AppleKeyboardUIMode
   
   # Text substitution settings (should show values)
   defaults read -g NSAutomaticCapitalizationEnabled
   defaults read -g NSAutomaticDashSubstitutionEnabled
   defaults read -g NSAutomaticPeriodSubstitutionEnabled
   defaults read -g NSAutomaticQuoteSubstitutionEnabled
   defaults read -g NSAutomaticSpellingCorrectionEnabled
   ```

### Step 6: Contingency - If System Settings Still Misbehaves

If System Settings still has issues after the above steps:

```bash
# Remove System Settings app containers and preferences
rm -rf ~/Library/Containers/com.apple.systempreferences
rm -f ~/Library/Preferences/com.apple.systempreferences.plist
sudo rm -f /Library/Preferences/com.apple.systempreferences.plist

# Kill preference daemon again
killall cfprefsd
sudo killall cfprefsd

# Rebuild
cd ~/nix-config
./scripts/build.sh switch

# Reboot as last resort
sudo reboot
```

## Validation Checklist

After completing the fix:
- [ ] System Settings opens normally
- [ ] All preference panes are visible in the sidebar
- [ ] Keyboard settings pane shows all options
- [ ] Text Input settings reflect your configuration
- [ ] No error messages when opening System Settings
- [ ] `defaults read -g` commands return expected values

## Prevention - Avoiding Future Conflicts

### Golden Rules

1. **Never duplicate NSGlobalDomain keys** between nix-darwin and home-manager
2. **System-wide settings belong in nix-darwin** modules
3. **User-specific settings belong in home-manager** modules
4. **When in doubt, use nix-darwin** for macOS system preferences

### Recommended Boundaries

**nix-darwin should manage:**
- System Preferences (Dock, Finder, Menu Bar)
- System-wide text input settings
- Global keyboard mappings (Caps Lock remapping)
- Security settings (firewall, etc.)
- System fonts and smoothing

**home-manager should manage:**
- User keyboard preferences (key repeat rates)
- User-specific hotkeys (symbolic hotkeys)
- Application-specific settings
- User environment variables
- User dotfiles and configs

## Commit Message

When committing these changes:
```bash
git add modules/home/macos/keybindings.nix \
        modules/darwin/system-defaults/default.nix \
        docs/SYSTEM-SETTINGS-FIX.md

git commit -m "fix(macos): resolve NSGlobalDomain conflict breaking System Settings

- Remove duplicate text-substitution keys from home-manager keybindings
- Document separation of concerns: nix-darwin manages system text input,
  home-manager manages user keyboard behavior
- Add comments to prevent future conflicts
- Fixes issue where System Settings displayed empty panes

Affected modules:
- modules/home/macos/keybindings.nix (removed NSAutomatic* keys)
- modules/darwin/system-defaults/default.nix (added clarifying comments)

See docs/SYSTEM-SETTINGS-FIX.md for cleanup procedure."
```

## Related Issues

This issue is a specific case of the broader challenge documented in:
- `docs/auth-architecture-analysis.md` - Multi-layer configuration conflicts
- WARP.md LAW 2 - Architectural boundaries are sacred
- WARP.md LAW 1.3 - No external state manipulation

## References

- nix-darwin `system.defaults` documentation
- home-manager `targets.darwin.defaults` documentation
- macOS `defaults` command documentation
- NSGlobalDomain preference domain specification
