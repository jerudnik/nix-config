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

#### **Current State:**

**`darwin/keyboard/default.nix`** writes:
```nix
system.defaults.NSGlobalDomain = {
  "com.apple.keyboard.fnState" = cfg.enableFnKeys;  # Function key behavior
};
```

**`darwin/system-settings/keyboard.nix`** (via default.nix) writes:
```nix
NSGlobalDomain = {
  KeyRepeat = cfg.keyboard.keyRepeat;
  InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
  ApplePressAndHoldEnabled = cfg.keyboard.pressAndHoldEnabled;
  AppleKeyboardUIMode = cfg.keyboard.keyboardUIMode;
};
```

**Resolution:** ✅ **COMPLETED** - All keyboard settings now unified in `system-settings/keyboard.nix`

---

## 📋 **Implemented Solution**

### **Merged keyboard module into system-settings**

Move all keyboard-related settings into `system-settings/keyboard.nix`:

```nix
# system-settings/keyboard.nix
options.darwin.system-settings.keyboard = {
  # Existing options
  keyRepeat = ...;
  initialKeyRepeat = ...;
  pressAndHoldEnabled = ...;
  keyboardUIMode = ...;
  
  # Add from darwin/keyboard module
  remapCapsLockToControl = mkOption {
    type = types.bool;
    default = true;
    description = "Remap Caps Lock key to Control";
  };
  
  remapCapsLockToEscape = mkOption {
    type = types.bool;
    default = false;
    description = "Remap Caps Lock key to Escape";
  };
  
  enableFnKeys = mkOption {
    type = types.bool;
    default = true;
    description = "Use F1, F2, etc. as standard function keys";
  };
};
```

Then update `system-settings/default.nix` config block:
```nix
system = {
  keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = cfg.keyboard.remapCapsLockToControl;
    remapCapsLockToEscape = cfg.keyboard.remapCapsLockToEscape;
  };
  
  defaults.NSGlobalDomain = {
    # Existing keyboard settings
    KeyRepeat = cfg.keyboard.keyRepeat;
    InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
    ApplePressAndHoldEnabled = cfg.keyboard.pressAndHoldEnabled;
    AppleKeyboardUIMode = cfg.keyboard.keyboardUIMode;
    
    # Add function key setting
    "com.apple.keyboard.fnState" = cfg.keyboard.enableFnKeys;
  };
};
```

**Implementation Details:**
1. ✅ Added keyboard remapping options to `system-settings/keyboard.nix`
2. ✅ Added function key option (`enableFnKeys`) to `system-settings/keyboard.nix`
3. ✅ Updated `system-settings/default.nix` with `system.keyboard` config block
4. ✅ Added fnState to NSGlobalDomain block in unified config
5. ✅ Removed standalone `darwin/keyboard` module
6. ✅ Updated host config to remove `darwin.keyboard` references

**Benefits Achieved:**
- ✅ Single source of truth for ALL keyboard settings
- ✅ Matches System Settings > Keyboard organization perfectly
- ✅ No NSGlobalDomain conflicts
- ✅ All keyboard config in one intuitive place
- ✅ Proper assertion preventing conflicting Caps Lock remappings

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

#### **window-manager**
- Scope: AeroSpace (deprecated, moved to home-manager)
- No NSGlobalDomain writes
- Status: ✅ Deprecated (can be removed)

#### **theming**
- Scope: Stylix theme management
- No NSGlobalDomain writes (Stylix manages its own preferences)
- Status: ✅ Clean

#### **fonts**
- Scope: Font installation via nix-darwin
- No NSGlobalDomain writes
- Status: ✅ Clean

---

## 📊 **Summary**

| Module | NSGlobalDomain? | Conflict? | Action Required |
|--------|----------------|-----------|-----------------|
| core | ❌ No | ✅ None | None |
| security | ❌ No | ✅ None | None |
| nix-settings | ❌ No | ✅ None | None |
| system-settings | ✅ Yes | ✅ None (unified) | None |
| homebrew | ❌ No | ✅ None | None |
| theming | ❌ No | ✅ None | None |
| fonts | ❌ No | ✅ None | None |

---

## 🎯 **Completed Actions**

1. ✅ **COMPLETED:** Merged `keyboard` module into `system-settings`
2. ✅ **COMPLETED:** Removed deprecated `window-manager` module
3. ✅ **DOCUMENTED:** system-settings is the single source of truth for all NSGlobalDomain settings

---

## 📝 **Notes**

- The keyboard conflict was caught early due to Phase 3 refactoring
- This demonstrates the value of the pane-based organization: all NSGlobalDomain writes are now visible in one place
- Future rule: ANY module that needs to write to NSGlobalDomain should do so through `system-settings`
