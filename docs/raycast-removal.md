# Raycast Removal Documentation

**Date:** October 8, 2025  
**Reason:** Suspected contributor to System Settings corruption; user switching to different launcher

## What Was Removed

### 1. Module Files
- ✅ **Deleted:** `/modules/home/raycast/` - Entire Raycast module directory
  - `default.nix` - Main module configuration
  - `README.md` - Module documentation

### 2. Configuration References

#### `home/jrudnik/home.nix`
- ✅ **Removed:** `outputs.homeManagerModules.raycast` import (line 11)
- ✅ **Removed:** `raycast` configuration block (lines 139-146)
  - Previously set to `enable = false`
  - Configured Cmd+Space hotkey
  - System appearance following settings
- ✅ **Removed:** Comment referencing "using Raycast for app launching" (line 9)

#### `modules/home/default.nix`
- ✅ **Removed:** `raycast = import ./raycast/default.nix;` export (line 9)
- ✅ **Removed:** Comment "# spotlight module removed - using Raycast for app launching"

#### `flake.nix`
- ✅ **Removed:** `"raycast"` from `allowUnfreePredicate` list (line 82)
  - No longer allowing unfree Raycast package

### 3. System Cleanup

#### Preference Files
- ✅ **Removed:** `~/Library/Preferences/com.raycast.macos.plist`
- ✅ **Removed:** `~/Library/Preferences/com.raycast.macos/` directory

#### Applications
- ✅ **Verified:** No Raycast applications in `~/Applications`
- ✅ **Verified:** No Raycast launch agents in `~/Library/LaunchAgents`

## What Raycast Was Doing

The Raycast module was configured to:

1. **Disable macOS Spotlight hotkeys** (Cmd+Space and Cmd+Option+Space)
   - This was done via `com.apple.symbolichotkeys` preference domain
   - **IMPORTANT:** These hotkeys are now re-enabled by default
   
2. **Install Raycast application** from nixpkgs
   - Required unfree package allowance
   
3. **Configure Raycast preferences** via `com.raycast.macos` domain
   - Global hotkey (Cmd+Space)
   - Follow system appearance
   - Onboarding completion flags
   
4. **Auto-start via launchd** (when enabled)
   - Background launch on login
   - Automatic restart on crash

## Impact on System

### Spotlight Behavior
Since Raycast was disabling Spotlight hotkeys, **Spotlight is now re-enabled** with default macOS hotkeys:
- **Cmd+Space** - Show Spotlight search
- **Cmd+Option+Space** - Show Finder search window

If you want to use a different launcher, you'll need to:
1. Disable Spotlight hotkeys manually in System Settings
2. Configure your new launcher's hotkeys
3. Or create a new module to manage these settings declaratively

### Symbolic Hotkeys
The keybindings module (`home/macos/keybindings.nix`) now has **sole ownership** of the `com.apple.symbolichotkeys` preference domain. This eliminates the conflict that was causing System Settings corruption.

## Alternative Launchers

If you want to use a different launcher, consider:

1. **Alfred** - Popular Spotlight replacement
   - Available via Homebrew: `brew install --cask alfred`
   - Requires manual hotkey configuration
   
2. **Ulauncher** - Free, open-source launcher
   - Cross-platform alternative
   
3. **macOS Spotlight** - Built-in (now re-enabled)
   - Zero configuration needed
   - Native integration

4. **Create your own module** - If you choose a new launcher:
   - Create a new module in `modules/home/`
   - Use `mkMerge` for `com.apple.symbolichotkeys` if disabling Spotlight
   - Follow the patterns in `modules/home/macos/keybindings.nix`

## Verification

After applying this configuration:

```bash
# Build and switch
darwin-rebuild switch --flake ~/nix-config#parsley

# Verify Raycast is not installed
ls ~/Applications/Home\ Manager\ Apps/ | grep -i raycast
# Should return nothing

# Verify Spotlight hotkey works
# Press Cmd+Space - should open Spotlight search

# Check System Settings
open "/System/Applications/System Settings.app"
# Navigate to Keyboard → Keyboard Shortcuts
# Verify Spotlight entries are enabled
```

## Next Steps

1. **Choose your launcher:**
   - Decide if you want to use macOS Spotlight, Alfred, or something else
   
2. **Configure hotkeys:**
   - If using a third-party launcher, disable Spotlight in System Settings
   - Set up your launcher's global hotkey
   
3. **Optional: Create new module:**
   - If you want declarative management of your new launcher
   - Follow the module template pattern
   - Remember to use `mkMerge` for symbolic hotkeys

## Rollback (If Needed)

If you need to restore Raycast, you can:

```bash
# Restore from git history
git log --all --oneline -- modules/home/raycast/
git checkout <commit-hash> -- modules/home/raycast/

# Re-add imports and configuration
# Edit home/jrudnik/home.nix
# Edit modules/home/default.nix
# Edit flake.nix

# Rebuild
darwin-rebuild switch --flake ~/nix-config#parsley
```

## Related Documentation

- `docs/preference-domain-audit.md` - Complete audit of preference domain conflicts
- `docs/SYSTEM-SETTINGS-FIX.md` - Original NSGlobalDomain conflict documentation
- `modules/home/macos/keybindings.nix` - Symbolic hotkeys management (sole owner now)
