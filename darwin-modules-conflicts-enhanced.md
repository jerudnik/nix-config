# Darwin Modules Conflict Analysis

This document identifies potential conflicts and overlaps between darwin modules, particularly focusing on NSGlobalDomain writes which can cause preference corruption.

## ✅ **CONFLICT RESOLVED**

### **Previous NSGlobalDomain Conflict: keyboard vs. system-settings**

**Status:** ✅ **RESOLVED** - keyboard module merged into system-settings

**Problem (Historical):** Both modules wrote to `NSGlobalDomain`, which could cause:
- Preference cache corruption (cfprefsd issues)
- Settings overwriting each other
- Blank System Settings panes
- Unpredictable behavior

---

## 📜 **Migration Timeline & Resolution**

### **Phase 1: Problem Discovery (October 2025)**

**Symptoms Identified:**
- System Settings displayed blank panes after `darwin-rebuild switch`
- Keyboard settings pane particularly affected
- Required restart to view settings
- Intermittent preference corruption

**Root Cause Analysis:**
1. **Multiple NSGlobalDomain Writers**: Both `darwin/system-defaults` and `darwin/keyboard` wrote to `NSGlobalDomain`
2. **No Coordination**: Sequential writes without cache synchronization
3. **cfprefsd Cache Corruption**: Preference daemon cached stale/conflicting data
4. **Home-manager Overlap**: `home/macos/keybindings` also wrote some NSGlobalDomain keys

**Research Documents:**
- `SYSTEM-SETTINGS-FIX.md` - Initial problem analysis and separation of concerns
- `preference-domain-audit.md` - Complete audit of all preference domain writes
- `system-settings-permanent-fix.md` - Comprehensive fix implementation

### **Phase 2: Architectural Solution (October 2025)**

**Decision:** Create unified `system-settings` module as single source of truth for ALL macOS System Settings

**Implementation Strategy:**
1. **Pane-Based Organization**: Mirror System Settings UI structure
   - `keyboard.nix` - Keyboard pane settings
   - `desktop-and-dock.nix` - Desktop & Dock pane
   - `appearance.nix` - Appearance pane
   - `trackpad.nix` - Trackpad pane
   - `general.nix` - General pane (including Finder)

2. **Unified Config Block**: Single coordinated NSGlobalDomain write in `default.nix`

3. **Cache Management**: Added critical activation scripts:
   ```nix
   # Kill cfprefsd to force cache flush after all writes
   /usr/bin/killall cfprefsd 2>/dev/null || true
   
   # Force macOS to reload preferences without logout
   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
   ```

4. **Validation**: Added preference file integrity checking

### **Phase 3: Migration Execution (October 2025)**

**Changes Made:**

#### **1. Merged keyboard module into system-settings**
- Added keyboard options to `system-settings/keyboard.nix`:
  - `keyRepeat` - Key repeat speed
  - `initialKeyRepeat` - Delay before repeat
  - `pressAndHoldEnabled` - Accent menu vs repeat
  - `keyboardUIMode` - Full keyboard access
  - `remapCapsLockToControl` - Caps Lock to Control
  - `remapCapsLockToEscape` - Caps Lock to Escape
  - `enableFnKeys` - Function key behavior

- Applied settings in unified config block (`system-settings/default.nix`)
- Removed standalone `darwin/keyboard` module
- Updated host configs to remove `darwin.keyboard` references

#### **2. Cleaned up home-manager keybindings**
- **Moved to nix-darwin** (`system-settings/keyboard.nix`):
  - `ApplePressAndHoldEnabled`
  - `InitialKeyRepeat`
  - `KeyRepeat`
  - `AppleKeyboardUIMode`

- **Kept in home-manager** (`home/macos/keybindings.nix`):
  - `com.apple.symbolichotkeys` (system hotkeys)
  - User-specific custom hotkeys

#### **3. Established clear boundaries**
- **nix-darwin manages** (via `system-settings`):
  - ALL NSGlobalDomain writes
  - System-wide keyboard/mouse/trackpad settings
  - Dock, Finder, appearance settings
  - Global text substitution

- **home-manager manages** (via targeted modules):
  - Application-specific preferences (`com.apple.*`, `com.microsoft.*`)
  - Symbolic hotkeys (`com.apple.symbolichotkeys`)
  - Launch Services handlers
  - User-specific settings

#### **4. Added Raycast conflict resolution**
- Discovered Raycast module also writing to `com.apple.symbolichotkeys`
- Added proper `mkMerge` to prevent overwriting keybindings
- Eventually removed Raycast module entirely per user request
- Documented in `raycast-removal.md`

### **Phase 4: Validation & Testing (October 2025)**

**Testing Performed:**
1. ✅ Build test without applying changes
2. ✅ Applied configuration with `darwin-rebuild switch`
3. ✅ Verified System Settings displays all panes correctly
4. ✅ Confirmed no restart required for changes
5. ✅ Validated preference file integrity
6. ✅ Confirmed cfprefsd cache synchronization

**Results:**
- ✅ System Settings displays correctly after rebuild
- ✅ No blank panes
- ✅ Settings apply immediately without restart
- ✅ No preference corruption
- ✅ Future rebuilds work correctly

---

## 🏗️ **Current Architecture**

### **System Settings Pane Mapping**

```nix
darwin.system-settings = {
  enable = true;
  
  # Maps to System Settings > Keyboard
  keyboard = {
    keyRepeat = 2;
    initialKeyRepeat = 15;
    pressAndHoldEnabled = false;
    keyboardUIMode = 3;
    remapCapsLockToControl = true;
    remapCapsLockToEscape = false;
    enableFnKeys = true;
  };
  
  # Maps to System Settings > Desktop & Dock
  desktopAndDock = {
    dock = {
      autohide = true;
      orientation = "bottom";
      tilesize = 48;
      # ... more dock settings
    };
    missionControl = {
      # ... mission control settings
    };
    hotCorners = {
      # ... hot corner settings
    };
  };
  
  # Maps to System Settings > Appearance
  appearance = {
    automaticSwitchAppearance = true;
  };
  
  # Maps to System Settings > Trackpad
  trackpad = {
    naturalScrolling = false;
    tapToClick = true;
  };
  
  # Maps to System Settings > General (+ Finder)
  general = {
    textInput = {
      smartQuotes = false;
      smartDashes = false;
      # ... more text input settings
    };
    finder = {
      showPathBar = true;
      showStatusBar = true;
      # ... more Finder settings
    };
  };
};
```

### **Implementation Details**

**File Structure:**
```
modules/darwin/system-settings/
├── default.nix              # Aggregator with unified config block
├── keyboard.nix             # Keyboard pane options
├── desktop-and-dock.nix     # Desktop & Dock pane options
├── appearance.nix           # Appearance pane options
├── trackpad.nix             # Trackpad pane options
└── general.nix              # General pane options
```

**Critical Implementation Pattern:**
```nix
# system-settings/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.darwin.system-settings;
in {
  imports = [
    ./desktop-and-dock.nix
    ./keyboard.nix
    ./appearance.nix
    ./trackpad.nix
    ./general.nix
  ];

  config = mkIf cfg.enable {
    # UNIFIED CONFIG BLOCK - Single coordinated write
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = cfg.keyboard.remapCapsLockToControl;
        remapCapsLockToEscape = cfg.keyboard.remapCapsLockToEscape;
      };
      
      defaults = {
        NSGlobalDomain = {
          # ALL NSGlobalDomain writes happen here in one place
          KeyRepeat = cfg.keyboard.keyRepeat;
          InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
          ApplePressAndHoldEnabled = cfg.keyboard.pressAndHoldEnabled;
          AppleKeyboardUIMode = cfg.keyboard.keyboardUIMode;
          "com.apple.keyboard.fnState" = cfg.keyboard.enableFnKeys;
          # ... all other NSGlobalDomain settings
        };
        
        dock = { /* dock settings */ };
        finder = { /* finder settings */ };
        trackpad = { /* trackpad settings */ };
      };
    };
    
    # Critical: Synchronize preferences and manage cfprefsd cache
    system.activationScripts.postActivation.text = ''
      echo "Synchronizing macOS preferences..."
      /usr/bin/killall cfprefsd 2>/dev/null || true
      sleep 2
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
      echo "Preferences synchronized successfully"
    '';
    
    # Validate preference file integrity
    system.activationScripts.validatePreferences.text = ''
      if ! /usr/bin/plutil -lint ~/.GlobalPreferences.plist > /dev/null 2>&1; then
        echo "WARNING: GlobalPreferences.plist is corrupted!" >&2
      else
        echo "✓ Preference validation passed"
      fi
    '';
  };
}
```

---

## 🔍 **Other Module Analysis**

### **✅ No Conflicts Found:**

#### **core**
- Scope: Essential packages, shell, system utilities
- No NSGlobalDomain writes
- Status: ✅ Clean

#### **security**
- Scope: Touch ID, user management, sudo
- No NSGlobalDomain writes
- Status: ✅ Clean

#### **nix-settings**
- Scope: Nix daemon, binary caches, garbage collection
- No NSGlobalDomain writes
- Status: ✅ Clean

#### **homebrew**
- Scope: Homebrew casks and Mac App Store apps
- No NSGlobalDomain writes
- Status: ✅ Clean

#### **theming**
- Scope: Stylix theme management
- No NSGlobalDomain writes (Stylix manages its own preferences)
- Status: ✅ Clean

#### **fonts**
- Scope: Font installation via nix-darwin
- Writes: `NSGlobalDomain.AppleFontSmoothing` (minimal, non-conflicting)
- Status: ✅ Clean

---

## 📊 **Preference Domain Matrix**

| Module | NSGlobalDomain? | Conflict? | Resolution |
|--------|----------------|-----------|------------|
| system-settings | ✅ Yes (unified) | ✅ None | Single source of truth |
| core | ❌ No | ✅ None | None needed |
| security | ❌ No | ✅ None | None needed |
| nix-settings | ❌ No | ✅ None | None needed |
| homebrew | ❌ No | ✅ None | None needed |
| theming | ❌ No | ✅ None | None needed |
| fonts | ✅ Yes (minimal) | ✅ None | Non-conflicting key |
| ~~keyboard~~ | ~~Yes~~ | ~~Conflict~~ | **Merged into system-settings** |

---

## 🎯 **Key Learnings**

### **1. Architectural Principles**

**Single Source of Truth:**
- One module should own each preference domain
- system-settings is the ONLY module that writes to NSGlobalDomain (except fonts' minimal write)
- Clear ownership prevents conflicts

**Pane-Based Organization:**
- Mirror macOS UI structure for intuitive configuration
- Users think in terms of System Settings panes, not preference domains
- Makes configuration discoverable and maintainable

**Unified Config Block:**
- All NSGlobalDomain writes must happen in one coordinated config block
- Prevents race conditions and cache corruption
- Enables proper cache management

### **2. Technical Insights**

**cfprefsd Management:**
- macOS caches preferences in cfprefsd daemon
- Must kill and restart after all writes complete
- `activateSettings -u` forces reload without logout
- Proper sequencing is critical

**Preference Validation:**
- Always validate .plist files after writes
- Corruption is detectable with `plutil -lint`
- Early detection prevents cascading issues

**Layer Separation:**
- nix-darwin for system-wide settings
- home-manager for user/application-specific settings
- Never duplicate keys between layers

### **3. Migration Best Practices**

**Planning:**
- Audit all preference domain writes first
- Identify all sources of NSGlobalDomain writes
- Plan unified architecture before implementing

**Execution:**
- Implement in phases with testing between
- Validate after each change
- Document architecture decisions

**Testing:**
- Test without applying (build-only)
- Apply and verify System Settings immediately
- Check for blank panes
- Validate preference files
- Test without restart

---

## 📝 **Future Guidelines**

### **Adding New System Settings**

When adding new macOS system preferences:

1. **Determine the pane**: Which System Settings pane does this belong to?
2. **Use system-settings**: Add options to the appropriate pane module
3. **Update unified config**: Add to the unified config block in `default.nix`
4. **Never bypass**: Don't create separate modules for system preferences
5. **Document**: Add to module-options.md

### **Preventing Future Conflicts**

**Rules to follow:**
- ✅ **ALWAYS** use `system-settings` for NSGlobalDomain writes
- ✅ **ALWAYS** use `mkMerge` when multiple modules write to same domain
- ✅ **ALWAYS** test System Settings after rebuild
- ❌ **NEVER** write NSGlobalDomain from multiple modules
- ❌ **NEVER** duplicate preference keys between nix-darwin and home-manager
- ❌ **NEVER** bypass the unified config block

### **Troubleshooting Checklist**

If System Settings shows blank panes:

1. **Check for conflicts**:
   ```bash
   grep -r "NSGlobalDomain" modules/darwin/
   grep -r "NSGlobalDomain" modules/home/
   ```

2. **Validate preference files**:
   ```bash
   plutil -lint ~/.GlobalPreferences.plist
   ```

3. **Check cfprefsd**:
   ```bash
   log stream --debug --predicate 'process == "cfprefsd"'
   ```

4. **Clean and rebuild**:
   ```bash
   ./scripts/fix-system-settings.sh  # If available
   # Or manually:
   killall "System Settings"
   killall cfprefsd
   sudo killall cfprefsd
   rm ~/.GlobalPreferences.plist
   darwin-rebuild switch --flake ~/nix-config#parsley
   ```

---

## 📚 **Related Documentation**

**Active Documentation:**
- `WARP.md` - LAW 5.4 documents system-settings domain authority
- `module-options.md` - Complete system-settings options reference
- `architecture.md` - Overall system design principles

**Archived Documentation:**
- `docs/archive/migrations/system-settings/SYSTEM-SETTINGS-FIX.md` - Original problem analysis
- `docs/archive/migrations/system-settings/preference-domain-audit.md` - Complete domain audit
- `docs/archive/migrations/system-settings/system-settings-permanent-fix.md` - Detailed fix implementation
- `docs/archive/migrations/system-settings/raycast-removal.md` - Raycast conflict resolution

---

## ✅ **Resolution Summary**

**Status:** ✅ **FULLY RESOLVED**

**Actions Completed:**
1. ✅ Identified NSGlobalDomain conflict between keyboard and system-settings
2. ✅ Designed pane-based system-settings architecture
3. ✅ Merged keyboard module into system-settings/keyboard.nix
4. ✅ Implemented unified config block
5. ✅ Added cfprefsd cache management
6. ✅ Added preference validation
7. ✅ Cleaned up home-manager keybindings
8. ✅ Resolved Raycast symbolic hotkeys conflict
9. ✅ Documented architecture and guidelines
10. ✅ Tested and validated solution

**Ongoing Compliance:**
- All darwin modules now follow single source of truth principle
- system-settings is the authoritative source for NSGlobalDomain
- Clear guidelines prevent future conflicts
- Architecture scales to additional System Settings panes

---

**Last Updated:** October 2025  
**Migration Status:** Complete ✅  
**Architecture:** Stable and production-ready
