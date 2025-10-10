# Phase 2: Execution Plan - Aggregator/Implementor Refactoring

## Overview

This document provides a detailed, step-by-step execution plan for refactoring the **4 HIGH PRIORITY** modules identified in the audit. Each module will be transformed using the aggregator/implementor pattern to separate abstract interfaces from concrete tool implementations.

---

## Refactoring Order & Rationale

### 1. darwin/theming (FIRST)
**Why First:**
- Perfect 8/8 score
- Clearest example of the pattern
- Least dependencies on other modules
- Sets the standard for subsequent refactorings
- High impact (affects all applications)

### 2. home/window-manager (SECOND)
**Why Second:**
- Also 8/8 score
- Can learn from theming refactoring
- Independent from other home modules
- High user value (productivity)

### 3. home/security (THIRD)
**Why Third:**
- Simpler than shell module
- Good practice before tackling shell
- Independent module
- Clear separation

### 4. home/shell (FOURTH)
**Why Last:**
- Most complex (220+ lines)
- Depends on understanding from previous refactorings
- Critical module - want maximum confidence
- Affects many other modules (aliases)

---

## Module 1: darwin/theming

### Current State
```
modules/darwin/theming/
└── default.nix (214 lines - monolithic)
```

### Target State
```
modules/darwin/theming/
├── default.nix    (Aggregator - 80-100 lines)
└── stylix.nix     (Implementor - 120-140 lines)
```

### Detailed Steps

#### Step 1.1: Backup and Prepare
- [x] Audit completed
- [ ] Create git branch: `refactor/phase2-theming`
- [ ] Read current implementation thoroughly
- [ ] Identify all Stylix-specific vs abstract options

#### Step 1.2: Create Stylix Implementor
- [ ] Rename `default.nix` to `stylix.nix` temporarily
- [ ] Wrap content in submodule: `darwin.theming.stylix.*`
- [ ] Keep all Stylix-specific logic:
  - `base16Scheme` path construction
  - Font package mappings
  - Theme switching script
  - Polarity configuration
- [ ] Update config condition: `mkIf cfg.enable` → `mkIf (cfg.enable && cfg.stylix.enable)`

**Stylix-specific options to keep:**
```nix
darwin.theming.stylix = {
  enable = mkEnableOption "Use Stylix for theming";
  # All current stylix.* configuration
};
```

#### Step 1.3: Create Aggregator
- [ ] Create new `default.nix`
- [ ] Define abstract theming API:
  ```nix
  darwin.theming = {
    enable = mkEnableOption "System-wide theming";
    
    # Tool-agnostic options
    colorScheme = mkOption { ... };
    autoSwitch = { ... };
    wallpaper = mkOption { ... };
    polarity = mkOption { ... };
    fonts = { ... };
  };
  ```
- [ ] Add imports: `imports = [ ./stylix.nix ];`
- [ ] Add documentation comments explaining the pattern

#### Step 1.4: Wire Up Stylix Implementor
- [ ] In `stylix.nix`, read from `cfg` (aggregator options)
- [ ] Map abstract options to Stylix configuration:
  ```nix
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
  stylix.polarity = cfg.polarity;
  # etc.
  ```

#### Step 1.5: Test
- [ ] Run `./scripts/build.sh check`
- [ ] Run `./scripts/build.sh build`
- [ ] Verify no options are broken
- [ ] Check that theming still works
- [ ] Verify auto-switch still functions

#### Step 1.6: Update Configuration
- [ ] Verify `hosts/parsley/configuration.nix` still works
- [ ] No changes should be needed (backward compatible)
- [ ] Optionally add `theming.stylix.enable = true;` for clarity

#### Step 1.7: Document
- [ ] Add comments explaining aggregator vs implementor
- [ ] Document how to add alternative implementors
- [ ] Update module documentation

**Expected Result:**
- ✅ Same user-facing API
- ✅ Clear separation of concerns
- ✅ Easy to add catppuccin.nix, base16.nix, etc.
- ✅ Configuration unchanged

**Rollback Plan:**
- Git revert to before branch
- Or: `git checkout main -- modules/darwin/theming/`

---

## Module 2: home/window-manager

### Current State
```
modules/home/window-manager/
└── default.nix (173 lines - monolithic)
```

### Target State
```
modules/home/window-manager/
├── default.nix      (Aggregator - 60-80 lines)
└── aerospace.nix    (Implementor - 120-140 lines)
```

### Detailed Steps

#### Step 2.1: Prepare
- [ ] Complete theming refactoring first
- [ ] Create git branch: `refactor/phase2-window-manager`
- [ ] Study theming pattern
- [ ] Identify AeroSpace-specific vs abstract options

#### Step 2.2: Create AeroSpace Implementor
- [ ] Rename `default.nix` to `aerospace.nix` temporarily
- [ ] Wrap in submodule: `home.window-manager.aerospace.*`
- [ ] Keep AeroSpace-specific elements:
  - TOML configuration generation
  - Keybinding definitions
  - Workspace management
  - Service mode

**AeroSpace-specific options:**
```nix
home.window-manager.aerospace = {
  enable = mkEnableOption "Use AeroSpace window manager";
  settings = mkOption { ... };  # AeroSpace-specific
  extraConfig = mkOption { ... };
};
```

#### Step 2.3: Create Aggregator
- [ ] Create new `default.nix`
- [ ] Define abstract window manager API:
  ```nix
  home.window-manager = {
    enable = mkEnableOption "Window management";
    
    # Tool-agnostic options (if any)
    autoStart = mkOption { ... };
    # Most config will be tool-specific
  };
  ```
- [ ] Add imports: `imports = [ ./aerospace.nix ];`

#### Step 2.4: Wire Up AeroSpace
- [ ] Map any abstract options to AeroSpace config
- [ ] Keep most configuration in aerospace.* namespace
- [ ] Install package: `home.packages = [ pkgs.aerospace ];`

#### Step 2.5: Test
- [ ] Build and verify
- [ ] Test AeroSpace launches correctly
- [ ] Verify keybindings work
- [ ] Check configuration file generation

#### Step 2.6: Update Configuration
- [ ] Update `home/jrudnik/home.nix`:
  ```nix
  window-manager.aerospace = {
    enable = true;
    # existing config
  };
  ```

**Expected Result:**
- ✅ Clear separation
- ✅ Easy to add yabai.nix, amethyst.nix
- ✅ Backward compatible

---

## Module 3: home/security

### Current State
```
modules/home/security/
└── default.nix (contains Bitwarden config)
```

### Target State
```
modules/home/security/
├── default.nix     (Aggregator - 40-60 lines)
└── bitwarden.nix   (Implementor - 80-100 lines)
```

### Detailed Steps

#### Step 3.1: Prepare
- [ ] Complete window-manager refactoring
- [ ] Create git branch: `refactor/phase2-security`
- [ ] Read current implementation
- [ ] Identify Bitwarden-specific options

#### Step 3.2: Create Bitwarden Implementor
- [ ] Extract Bitwarden config to `bitwarden.nix`
- [ ] Wrap in submodule: `home.security.bitwarden.*`
- [ ] Keep Bitwarden-specific:
  - Touch ID settings
  - Tray behavior
  - CLI integration
  - Lock timeout

#### Step 3.3: Create Aggregator
- [ ] Create new `default.nix`
- [ ] Define abstract security API:
  ```nix
  home.security = {
    enable = mkEnableOption "Security tools";
    
    # Abstract password manager options (if any common)
    passwordManager = {
      autoLock = mkOption { ... };
      biometricAuth = mkOption { ... };
    };
  };
  ```
- [ ] Add imports: `imports = [ ./bitwarden.nix ];`

#### Step 3.4: Wire Up Bitwarden
- [ ] Map abstract options to Bitwarden settings
- [ ] Keep most config in bitwarden.* namespace

#### Step 3.5: Test
- [ ] Build and verify
- [ ] Test Bitwarden launches
- [ ] Verify Touch ID works
- [ ] Check all settings apply

#### Step 3.6: Update Configuration
- [ ] Update `home/jrudnik/home.nix`:
  ```nix
  security.bitwarden = {
    enable = true;
    # existing config
  };
  ```

**Expected Result:**
- ✅ Easy to add 1Password, KeePassXC implementors
- ✅ Clear password manager abstraction
- ✅ Backward compatible

---

## Module 4: home/shell

### Current State
```
modules/home/shell/
└── default.nix (220+ lines - monolithic)
```

### Target State
```
modules/home/shell/
├── default.nix    (Aggregator - 80-100 lines)
└── zsh.nix        (Implementor - 140-160 lines)
```

### Detailed Steps

#### Step 4.1: Prepare
- [ ] Complete all previous refactorings
- [ ] Create git branch: `refactor/phase2-shell`
- [ ] Deep analysis of alias management
- [ ] Identify Zsh/oh-my-zsh specific options

#### Step 4.2: Create Zsh Implementor
- [ ] Extract Zsh config to `zsh.nix`
- [ ] Wrap in submodule: `home.shell.zsh.*`
- [ ] Keep Zsh-specific:
  - oh-my-zsh configuration
  - Zsh-specific aliases
  - Completion setup
  - initContent

**Zsh-specific options:**
```nix
home.shell.zsh = {
  enable = mkEnableOption "Use Zsh shell";
  ohMyZsh = { ... };
  # Zsh-specific options
};
```

#### Step 4.3: Create Aggregator
- [ ] Create new `default.nix`
- [ ] Define abstract shell API:
  ```nix
  home.shell = {
    enable = mkEnableOption "Shell configuration";
    
    # Tool-agnostic
    aliases = mkOption { ... };
    modernTools = { ... };
    enableNixShortcuts = mkOption { ... };
    configPath = mkOption { ... };
    hostName = mkOption { ... };
  };
  ```
- [ ] Add imports: `imports = [ ./zsh.nix ];`

#### Step 4.4: Wire Up Zsh
- [ ] Map abstract aliases to Zsh shellAliases
- [ ] Handle modern tool aliases
- [ ] Preserve Nix shortcuts

#### Step 4.5: Test THOROUGHLY
- [ ] Build and verify
- [ ] Test shell launches correctly
- [ ] Verify ALL aliases work
- [ ] Test Nix shortcuts
- [ ] Check modern tools integration
- [ ] Test oh-my-zsh themes/plugins

#### Step 4.6: Update Configuration
- [ ] Update `home/jrudnik/home.nix`:
  ```nix
  shell.zsh = {
    enable = true;
    ohMyZsh = {
      theme = "robbyrussell";
      plugins = [ "git" "macos" ];
    };
  };
  ```

**Expected Result:**
- ✅ Easy to add bash.nix, fish.nix implementors
- ✅ Clear shell abstraction
- ✅ Alias management preserved
- ✅ Backward compatible

---

## Testing Strategy

### Per-Module Testing
After each module refactoring:
1. **Build Test**: `./scripts/build.sh build`
2. **Check Test**: `./scripts/build.sh check`
3. **Switch Test**: `./scripts/build.sh switch` (only after successful build)
4. **Functional Test**: Verify the module's functionality works
5. **Regression Test**: Ensure other modules still work

### Integration Testing
After all modules refactored:
1. Full system build
2. Full system switch
3. Test all 4 refactored modules work together
4. Verify no regressions in other modules
5. Test theme switching
6. Test window manager operations
7. Test shell aliases
8. Test Bitwarden integration

---

## Risk Assessment

### Low Risk
- **darwin/theming**: Well-isolated, clear API
- **home/security**: Simple, few dependencies

### Medium Risk
- **home/window-manager**: Complex config generation, but isolated

### High Risk
- **home/shell**: Critical module, many dependencies, complex alias system
  - **Mitigation**: Do last, test exhaustively, have rollback ready

---

## Rollback Strategy

### Per-Module Rollback
```bash
# If module X breaks
git checkout main -- modules/darwin/X/
git checkout main -- modules/home/X/
./scripts/build.sh switch
```

### Full Rollback
```bash
# If entire refactoring breaks
git checkout main
./scripts/build.sh switch
```

### Safe Testing Approach
1. Always test `build` before `switch`
2. Keep terminal open with working shell
3. Don't close all terminals until verified
4. Have backup configuration method ready

---

## Documentation Updates

After all refactorings:

### 1. Update WARP.md
- [ ] Add new LAW: AGGREGATOR/IMPLEMENTOR PATTERN
- [ ] Document when to use this pattern
- [ ] Provide theming module as canonical example
- [ ] Add guidelines for creating new modules

### 2. Update docs/architecture.md
- [ ] Document the pattern
- [ ] Show before/after examples
- [ ] Explain benefits

### 3. Update docs/modular-architecture.md
- [ ] Detailed pattern explanation
- [ ] Code examples from refactored modules
- [ ] Best practices
- [ ] Anti-patterns to avoid

### 4. Update docs/module-options.md
- [ ] Reflect new module structures
- [ ] Document new option namespaces
- [ ] Update examples

---

## Success Criteria

### Technical
- ✅ All modules build successfully
- ✅ All functionality preserved
- ✅ No regressions
- ✅ Clean separation achieved

### Architectural
- ✅ Clear aggregator/implementor separation
- ✅ Tool-agnostic APIs defined
- ✅ Easy to add new implementors
- ✅ Pattern is repeatable

### User Experience
- ✅ Configuration syntax unchanged (backward compatible)
- ✅ All features still work
- ✅ No performance degradation
- ✅ Better maintainability

### Documentation
- ✅ Pattern well-documented
- ✅ Examples clear
- ✅ Guidelines established
- ✅ Future developers can follow pattern

---

## Timeline Estimate

### Conservative Estimate
- **Module 1 (theming)**: 2-3 hours
- **Module 2 (window-manager)**: 1.5-2 hours
- **Module 3 (security)**: 1-1.5 hours
- **Module 4 (shell)**: 3-4 hours
- **Testing & Documentation**: 2-3 hours
- **Total**: 10-14 hours

### Aggressive Estimate
- **Module 1**: 1 hour
- **Module 2**: 45 min
- **Module 3**: 30 min
- **Module 4**: 2 hours
- **Testing & Documentation**: 1.5 hours
- **Total**: 6-7 hours

**Recommendation**: Plan for conservative estimate, celebrate if faster!

---

## Next Action

Ready to begin? Start with:
```bash
git checkout -b refactor/phase2-theming
```

Then proceed with **Module 1: darwin/theming** refactoring steps.
