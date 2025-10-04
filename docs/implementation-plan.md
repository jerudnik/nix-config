# Elegant Implementation Plan: Productivity Enhancements

**Goal**: Implement 3 high-impact productivity improvements that follow existing module patterns and maintain WARP.md compliance.

---

## 📋 **Current Architecture Analysis**

### **Existing Module Strengths:**
- ✅ **Consistent patterns**: All modules follow the same option structure
- ✅ **Rich configuration**: Comprehensive options with sensible defaults
- ✅ **Clean separation**: Git, shell, development, and system modules are well-organized
- ✅ **WARP.md compliant**: All packages via nixpkgs, proper typing, good documentation

### **Enhancement Opportunities:**
1. **Git aliases** - Currently empty `{}` in home.nix
2. **Shell productivity** - Basic aliases, room for workflow shortcuts
3. **System polish** - Good foundation, missing keyboard/trackpad settings
4. **GitHub integration** - Missing GitHub CLI from development tools

---

## 🎯 **Implementation Strategy**

### **Design Principles:**
- **Extend, don't replace** existing functionality
- **Follow established patterns** (options structure, defaults, descriptions)
- **Maintain WARP.md compliance** (nixpkgs-first, proper types)
- **User-configurable** with sensible defaults
- **Backwards compatible** with existing configurations

---

## 🚀 **Enhancement 1: Git Workflow Productivity**

### **Approach:** Extend existing git module with productive default aliases

### **Current State:**
- Git module has `aliases = {}` option (ready for enhancement)
- User config sets `aliases = {}` (empty)

### **Enhancement:** Add curated git aliases with user override support

#### **Implementation:**

**File**: `modules/home/git/default.nix`
**Changes**: Add `defaultAliases` option and smart merging

```nix
# Add new option (around line 48, after aliases option)
defaultAliases = {
  enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable curated productive git aliases";
  };
  
  set = mkOption {
    type = types.enum [ "essential" "productive" "comprehensive" ];
    default = "productive";
    description = ''
      Alias set level:
      - essential: Most common shortcuts (st, co, br)
      - productive: Workflow-focused aliases (pushf, unstage, fixup)
      - comprehensive: Full set including advanced workflows
    '';
  };
};
```

**Default Alias Sets:**
```nix
let
  # Define alias sets
  essentialAliases = {
    st = "status";
    co = "checkout"; 
    br = "branch";
    ci = "commit";
  };
  
  productiveAliases = essentialAliases // {
    pushf = "push --force-with-lease";
    unstage = "reset HEAD --";
    fixup = "commit --fixup";
    amend = "commit --amend";
    undo = "reset --soft HEAD~1";
    last = "log -1 HEAD";
    visual = "log --oneline --graph --decorate --all";
  };
  
  comprehensiveAliases = productiveAliases // {
    # Workflow aliases
    wip = "commit -am 'WIP'";
    unwip = "reset --soft HEAD~1";
    assume = "update-index --assume-unchanged";
    unassume = "update-index --no-assume-unchanged";
    assumed = "!git ls-files -v | grep ^h | cut -c 3-";
    
    # Branch management
    cleanup = "branch --merged | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d";
    recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'";
    
    # Advanced workflows
    please = "push --force-with-lease";
    commend = "commit --amend --no-edit";
  };
  
  # Select alias set based on configuration
  selectedAliases = 
    if cfg.defaultAliases.set == "essential" then essentialAliases
    else if cfg.defaultAliases.set == "productive" then productiveAliases  
    else comprehensiveAliases;
    
  # Merge with user aliases (user aliases take precedence)
  finalAliases = selectedAliases // cfg.aliases;
```

### **User Configuration:**
```nix
# In home/jrudnik/home.nix
home.git = {
  enable = true;
  userName = "jrudnik";
  userEmail = "john.rudnik@gmail.com";
  
  # Use default productive aliases
  defaultAliases = {
    enable = true;
    set = "productive";  # or "essential" or "comprehensive"
  };
  
  # Add personal aliases (these override defaults)
  aliases = {
    deploy = "push origin main";  # Custom workflow
    # Any user aliases override defaults
  };
};
```

---

## 💻 **Enhancement 2: Shell Productivity Shortcuts**

### **Approach:** Extend existing shell module with workflow-specific aliases

### **Current State:**
- Shell module has comprehensive alias system
- User config sets `aliases = {}` (empty)
- Good modern CLI tool integration

### **Enhancement:** Add productivity-focused aliases with smart defaults

#### **Implementation:**

**File**: `modules/home/shell/default.nix`
**Changes**: Add `productivityAliases` option

```nix
# Add new option (around line 40, after modernTools)
productivityAliases = {
  enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable productivity-focused shell aliases";
  };
  
  includeSystemShortcuts = mkOption {
    type = types.bool;
    default = true;
    description = "Include macOS system management shortcuts";
  };
  
  includeNetworkUtils = mkOption {
    type = types.bool;
    default = true;
    description = "Include network diagnostic utilities";
  };
  
  includeDevShortcuts = mkOption {
    type = types.bool;
    default = true;
    description = "Include development workflow shortcuts";
  };
};
```

**Productivity Alias Sets:**
```nix
# Add to existing shellAliases (around line 182, before cfg.aliases)
}) // (optionalAttrs cfg.productivityAliases.enable {
  # Quick navigation
  config = "cd ${cfg.configPath}";
  home = "cd $HOME";
  desktop = "cd $HOME/Desktop";
  downloads = "cd $HOME/Downloads";
  projects = "cd $HOME/Projects";  # Assumes typical project structure
  
  # File operations
  mkcd = "mkdir -p $1 && cd $1";  # Create and enter directory
  backup = "cp $1{,.backup}";     # Quick backup copy
  
}) // (optionalAttrs (cfg.productivityAliases.enable && cfg.productivityAliases.includeSystemShortcuts) {
  # macOS system shortcuts
  flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
  showfiles = "defaults write com.apple.finder AppleShowAllFiles YES && killall Finder";
  hidefiles = "defaults write com.apple.finder AppleShowAllFiles NO && killall Finder";
  emptytrash = "sudo rm -rfv ~/.Trash/*";
  
  # System information
  battery = "pmset -g batt";
  sleep = "pmset sleepnow";
  
}) // (optionalAttrs (cfg.productivityAliases.enable && cfg.productivityAliases.includeNetworkUtils) {
  # Network utilities
  localip = "ipconfig getifaddr en0 || ipconfig getifaddr en1";
  publicip = "curl -s https://httpbin.org/ip | jq -r .origin";
  speedtest = "curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -";
  
}) // (optionalAttrs (cfg.productivityAliases.enable && cfg.productivityAliases.includeDevShortcuts) {
  # Development shortcuts
  serve8000 = "python3 -m http.server 8000";
  serve3000 = "python3 -m http.server 3000"; 
  jsonpp = "python3 -m json.tool";  # Pretty print JSON
  urlencode = "python3 -c 'import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))'";
  urldecode = "python3 -c 'import urllib.parse, sys; print(urllib.parse.unquote_plus(sys.argv[1]))'";
  
  # Git workflow helpers (complement git aliases)
  gitroot = "cd $(git rev-parse --show-toplevel)";  # Go to git repo root
  
}) // cfg.aliases;
```

### **User Configuration:**
```nix
# In home/jrudnik/home.nix
home.shell = {
  enable = true;
  configPath = "~/nix-config";
  hostName = "parsley";
  
  # Enable productivity aliases
  productivityAliases = {
    enable = true;
    includeSystemShortcuts = true;
    includeNetworkUtils = true; 
    includeDevShortcuts = true;
  };
  
  # Custom aliases
  aliases = {
    # Your personal shortcuts
  };
};
```

---

## ⚙️ **Enhancement 3: macOS System Polish**

### **Approach:** Extend existing system-defaults module with keyboard/trackpad/performance settings

### **Current State:**
- Good foundation with dock, finder, global settings
- Missing keyboard, trackpad, energy settings

### **Enhancement:** Add input device and performance options

#### **Implementation:**

**File**: `modules/darwin/system-defaults/default.nix`
**Changes**: Add keyboard, trackpad, and performance sections

```nix
# Add new option sections (after globalDomain, around line 102)

keyboard = {
  enableFastKeyRepeat = mkOption {
    type = types.bool;
    default = true;
    description = "Enable fast key repeat for productivity";
  };
  
  keyRepeat = mkOption {
    type = types.int;
    default = 2;
    description = "Key repeat rate (1-2 is fast, 10 is slow)";
  };
  
  initialKeyRepeat = mkOption {
    type = types.int; 
    default = 15;
    description = "Delay before key repeat starts (10-15 is fast)";
  };
  
  disablePressAndHold = mkOption {
    type = types.bool;
    default = true;
    description = "Disable press-and-hold for accent characters (enables key repeat for all keys)";
  };
};

trackpad = {
  clicking = mkOption {
    type = types.bool;
    default = true;
    description = "Enable tap to click";
  };
  
  threeFingerDrag = mkOption {
    type = types.bool;
    default = true;
    description = "Enable three finger drag";
  };
  
  rightClick = mkOption {
    type = types.enum [ "TwoButtonSwipeFromRightEdge" "TwoButtonSwipeFromBottomRightCorner" "OneButtonClickWithTwoFingers" ];
    default = "TwoButtonSwipeFromRightEdge";
    description = "Right click gesture";
  };
};

performance = {
  minimizeToApplicationIcon = mkOption {
    type = types.bool;
    default = true;
    description = "Minimize windows into their application icon";
  };
  
  disableWindowAnimations = mkOption {
    type = types.bool;
    default = false;
    description = "Disable window animations for faster performance";
  };
  
  reduceMotion = mkOption {
    type = types.bool;
    default = false;
    description = "Reduce motion throughout the system";
  };
};
```

**System Configuration (in config section):**
```nix
# Add to system.defaults (around line 154, before closing)

# Keyboard settings
NSGlobalDomain = {
  # ... existing settings ...
  
  # Keyboard enhancements
} // (optionalAttrs cfg.keyboard.enableFastKeyRepeat {
  KeyRepeat = cfg.keyboard.keyRepeat;
  InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
  ApplePressAndHoldEnabled = !cfg.keyboard.disablePressAndHold;
});

# Trackpad settings  
trackpad = {
  Clicking = cfg.trackpad.clicking;
  TrackpadThreeFingerDrag = cfg.trackpad.threeFingerDrag;
  TrackpadRightClick = true;
  TrackpadCornerSecondaryClick = 
    if cfg.trackpad.rightClick == "TwoButtonSwipeFromBottomRightCorner" then 2
    else 0;
};

# Performance settings
dock = {
  # ... existing dock settings ...
  minimize-to-application = cfg.performance.minimizeToApplicationIcon;
  enable-spring-load-actions-on-all-items = true;
} // (optionalAttrs cfg.performance.disableWindowAnimations {
  launchanim = false;
});

# Accessibility (for reduce motion)
universalaccess = mkIf cfg.performance.reduceMotion {
  reduceMotion = true;
};
```

### **User Configuration:**
```nix
# In hosts/parsley/configuration.nix
darwin.system-defaults = {
  enable = true;
  
  # Enhanced input settings
  keyboard = {
    enableFastKeyRepeat = true;
    keyRepeat = 2;           # Fast repeat
    initialKeyRepeat = 15;   # Quick start
    disablePressAndHold = true;  # Enable repeat for all keys
  };
  
  trackpad = {
    clicking = true;         # Tap to click
    threeFingerDrag = true;  # Drag with three fingers
    rightClick = "TwoButtonSwipeFromRightEdge";
  };
  
  performance = {
    minimizeToApplicationIcon = true;
    disableWindowAnimations = false;  # Keep animations for nice UX
    reduceMotion = false;
  };
  
  # All existing settings remain the same
};
```

---

## 🐙 **Enhancement 4: GitHub Integration**

### **Approach:** Add GitHub CLI to existing development module

### **Current State:**
- Development module has `extraPackages` option (perfect for this)
- Clean pattern for adding development tools

### **Enhancement:** Add GitHub CLI with smart defaults

#### **Implementation:**

**File**: `modules/home/development/default.nix`  
**Changes**: Add GitHub CLI option and integration

```nix
# Add new option (around line 26, after neovim option)
githubCli = mkOption {
  type = types.bool;
  default = true;
  description = "Enable GitHub CLI (gh) for repository management";
};
```

**Package Addition:**
```nix
# Add to home.packages (around line 84, before cfg.extraPackages)
# GitHub CLI
++ optionals cfg.githubCli [ gh ]

# Extra packages
++ cfg.extraPackages
```

### **User Configuration:**
```nix
# In home/jrudnik/home.nix  
home.development = {
  enable = true;
  languages = {
    rust = true;
    go = true; 
    python = true;
  };
  editor = "micro";
  emacs = true;
  
  # Enable GitHub CLI
  githubCli = true;  # Default is true anyway
};
```

---

## 📝 **Step-by-Step Implementation Guide**

### **Phase 1: Git Productivity (5 minutes)**

1. **Edit** `modules/home/git/default.nix`:
   - Add `defaultAliases` options
   - Add alias sets and merging logic  
   - Update `aliases = finalAliases;` in config

2. **No changes needed** in `home/jrudnik/home.nix` (defaults work)

3. **Test**:
   ```bash
   ./scripts/build.sh build
   # Should build without errors
   ```

### **Phase 2: Shell Productivity (5 minutes)**

1. **Edit** `modules/home/shell/default.nix`:
   - Add `productivityAliases` options
   - Add productivity alias sets
   - Insert before `cfg.aliases` in shellAliases

2. **No changes needed** in `home/jrudnik/home.nix` (defaults work)

3. **Test**:
   ```bash
   ./scripts/build.sh build
   ```

### **Phase 3: macOS Polish (10 minutes)**

1. **Edit** `modules/darwin/system-defaults/default.nix`:
   - Add keyboard, trackpad, performance options
   - Add corresponding system.defaults configuration

2. **No changes needed** in `hosts/parsley/configuration.nix` (defaults work)

3. **Test**:
   ```bash
   ./scripts/build.sh build
   ```

### **Phase 4: GitHub Integration (2 minutes)**

1. **Edit** `modules/home/development/default.nix`:
   - Add `githubCli` option
   - Add `gh` package to home.packages

2. **No changes needed** in `home/jrudnik/home.nix` (default is true)

3. **Test**:
   ```bash
   ./scripts/build.sh build
   ```

### **Phase 5: Apply Changes (5 minutes)**

1. **Switch to new configuration**:
   ```bash
   sudo darwin-rebuild switch --flake .#parsley
   ```

2. **Verify enhancements**:
   ```bash
   # Test git aliases
   git st  # Should show status
   
   # Test shell shortcuts  
   config  # Should cd to ~/nix-config
   localip # Should show local IP
   
   # Test GitHub CLI
   gh --version  # Should show GitHub CLI version
   
   # Test system settings (check in System Preferences)
   # Trackpad -> Point & Click -> Tap to click (should be enabled)
   # Keyboard -> Key Repeat (should be fast)
   ```

---

## 🎉 **Benefits Summary**

### **Git Productivity:**
- **15+ productive aliases** out of the box
- **User customizable** alias sets (essential/productive/comprehensive)
- **Backwards compatible** with existing empty aliases

### **Shell Productivity:**  
- **20+ workflow shortcuts** for common tasks
- **Smart categorization** (system/network/dev shortcuts)
- **macOS-specific utilities** (DNS flush, show hidden files)

### **macOS Polish:**
- **Fast keyboard repeat** for productivity
- **Tap to click** and three-finger drag
- **Application-focused** minimize behavior
- **Performance optimizations**

### **GitHub Integration:**
- **GitHub CLI** for repository management
- **Seamless integration** with existing development workflow
- **Optional** but enabled by default

### **Architecture Benefits:**
- ✅ **Follows existing patterns** exactly
- ✅ **WARP.md compliant** (all packages via nixpkgs)
- ✅ **User configurable** with sensible defaults
- ✅ **Backwards compatible** with current config
- ✅ **Easy to maintain** and extend

**Total Implementation Time: ~30 minutes**
**Total Enhancement Value: Significant daily productivity improvement**