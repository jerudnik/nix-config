# WARP.md - MANDATORY CONFIGURATION RULES

**⚠️ CRITICAL: This file contains MANDATORY RULES that must be followed without exception when working with this nix-config repository. These are not suggestions or guidelines - they are hard requirements.**

**🚫 VIOLATIONS WILL BE REJECTED 🚫**

---

## QUICK REFERENCE FOR AGENTS

**Before making any changes, answer these questions:**

### 1. **What am I modifying?**
- System-level macOS settings → `modules/darwin/system-settings/`
- User dotfiles/CLI tools → `modules/home/`
- GUI application installation → `modules/darwin/` (environment.systemPackages)
- Package available in nixpkgs? → Use nixpkgs module directly (NEVER create custom wrapper)

### 2. **Does a module already exist?**
- ✅ Check: `programs.<name>` in nixpkgs/home-manager first
- ✅ Check: Current module structure in `modules/darwin/` and `modules/home/`
- ✅ If exists: Use it directly, don't wrap it

### 3. **Have I registered the module?**
- ✅ Check: `modules/home/default.nix` (for user modules)
- ✅ Check: `modules/darwin/default.nix` (for system modules)
- ✅ If not: Add the new module to the appropriate `default.nix` file.

### 4. **Where do NSGlobalDomain writes go?**
- **ONLY** in `modules/darwin/system-settings/` (LAW 5, RULE 5.4)
- Any keyboard, trackpad, dock, appearance settings → `system-settings` panes

### 4. **Build workflow:**
```bash
./scripts/build.sh build   # ALWAYS test first
./scripts/build.sh switch  # Only after build succeeds
```

---

## DECISION FLOWCHART: WHERE DOES THIS GO?

```
┌─────────────────────────────────────┐
│ What are you configuring?           │
└─────────────┬───────────────────────┘
              │
              ├─→ macOS System Settings (Dock, Keyboard, etc.)?
              │   └─→ modules/darwin/system-settings/<pane>.nix
              │
              ├─→ GUI Application Installation?
              │   └─→ modules/darwin/ + environment.systemPackages
              │
              ├─→ System Service (Nix daemon, fonts, etc.)?
              │   └─→ modules/darwin/<service>/
              │
              ├─→ User Dotfiles or Config Files?
              │   └─→ modules/home/<category>/
              │
              ├─→ CLI Tool Installation + Config?
              │   ├─→ Has nixpkgs module? → Use programs.<tool>
              │   └─→ No nixpkgs module? → modules/home/<category>/
              │
              └─→ NSGlobalDomain write?
                  └─→ STOP! Only allowed in system-settings
```

---

# CONFIGURATION PURITY LAWS

## LAW 1: DECLARATIVE ONLY - NO IMPERATIVE ACTIONS

**RULE 1.1: No Manual System Modifications**
- ❌ **NEVER** run scripts or commands outside of nix-config to configure applications
- ❌ **NEVER** use manual `defaults write`, `plutil`, `osascript`, or system modification commands
- ❌ **NEVER** create or modify files outside the nix-config directory tree
- ✅ **ONLY** use declarative configuration through the module system
- ✅ **ONLY** modify files within `/Users/jrudnik/nix-config/`

**RULE 1.2: Build Script Adherence**
- ❌ **NEVER** use `darwin-rebuild` directly without using provided scripts
- ❌ **NEVER** use `sudo darwin-rebuild switch --flake` manually
- ✅ **ALWAYS** use `./scripts/build.sh build` to test
- ✅ **ALWAYS** use `./scripts/build.sh switch` to apply
- ✅ **ALWAYS** use `./scripts/build.sh check` to validate

**RULE 1.3: No External State Manipulation**
- ❌ **NEVER** create activation scripts that modify external files
- ❌ **NEVER** use `home.activation.*` to run system commands
- ❌ **NEVER** modify system state outside of nix-darwin/home-manager mechanisms
- ✅ **ONLY** use `targets.darwin.defaults` for system preferences
- ✅ **ONLY** use home-manager's built-in configuration options

---

## LAW 2: ARCHITECTURAL BOUNDARIES ARE SACRED

**RULE 2.1: Module Responsibility Separation**
- ❌ NEVER put Darwin-specific options in NixOS modules or vice versa
- ✅ ALWAYS keep modules/darwin/, modules/nixos/, and modules/home/ strictly separate
- ✅ ALWAYS use the correct module type for the configuration layer, following the strict division of labor:
	- modules/darwin/: Manages system-level concerns. This includes the installation of all GUI applications, system-wide services, and macOS defaults
	- modules/home/: Manages user-level concerns. This includes the configuration of applications (whose installation is managed by nix-darwin), the installation and configuration of CLI-only tools, and all user-specific dotfiles

**RULE 2.2: One Module, One Concern**
- ❌ NEVER create monolithic modules that handle multiple unrelated features
- ✅ ALWAYS create focused, single-responsibility modules
- ✅ ALWAYS name modules by their function (the "what"), not their implementation (the "how"). For example, a module for theming should be named theming, even if it uses stylix internally
- ✅ GUIDELINE: Keep modules under ~100 lines when possible. Larger modules are acceptable for complex, cohesive functionality but should be reviewed for splitting opportunities

**RULE 2.3: Platform Separation Enforcement**
- ❌ NEVER use platform conditionals (e.g., if pkgs.stdenv.isDarwin) in system modules
- ❌ NEVER mix Darwin and NixOS concerns in a single module
- ✅ ALWAYS create separate Darwin and NixOS modules for platform-specific features
- ✅ ALWAYS use the appropriate module system: nix-darwin for macOS, NixOS for Linux

**RULE 2.4: Nixpkgs-First Module Creation**
- ❌ NEVER create custom modules for programs that have nixpkgs modules (e.g., programs.zsh, programs.git)
- ❌ NEVER wrap existing nixpkgs modules in custom modules without substantial added value
- ✅ ALWAYS check if nixpkgs or home-manager already provides a module before creating a custom one
- ✅ ALWAYS use nixpkgs modules directly when they exist
- ✅ ONLY create custom modules for programs without nixpkgs modules or when adding significant custom functionality

---

## LAW 3: TYPE SAFETY AND VALIDATION

**RULE 3.1: Strict Type Usage**
- ❌ NEVER use types.str when more specific types exist (e.g., types.path for paths, types.enum for limited choices)
- ❌ NEVER use types.anything or types.attrs without clear justification
- ✅ ALWAYS use the most specific type available for each option
- ✅ ALWAYS use types.enum when options have a limited set of valid values
- ✅ ALWAYS use types.submodule for structured configuration

**RULE 3.2: Documentation Requirements**
- ❌ NEVER create options without descriptions
- ❌ NEVER use vague descriptions like "enables the feature"
- ✅ ALWAYS provide clear, meaningful descriptions for every option
- ✅ ALWAYS explain the impact and behavior of each option
- ✅ ALWAYS include examples for complex options

**RULE 3.3: Default Value Mandates**
- ❌ NEVER leave options without sensible defaults
- ❌ NEVER use defaults that require additional configuration to work
- ✅ ALWAYS provide working default values for all options
- ✅ ALWAYS ensure modules work with minimal configuration
- ✅ PRINCIPLE: Simple cases should be simple - complex cases should be possible

---

## LAW 4: BUILD AND TEST DISCIPLINE

**RULE 4.1: Incremental Testing Protocol**
- ❌ NEVER make multiple unrelated changes in one commit
- ❌ NEVER apply changes without building first
- ✅ ALWAYS test with `./scripts/build.sh build` before applying
- ✅ ALWAYS make one logical change at a time
- ✅ ALWAYS ensure each commit represents a working state

**RULE 4.2: Configuration Logic Restrictions**
- ❌ NEVER put complex logic in host-specific configuration files
- ❌ NEVER use conditionals in host configs when modules can handle it
- ✅ ALWAYS keep host configs simple and declarative
- ✅ ALWAYS move complex logic into reusable modules
- ✅ PRINCIPLE: Host configs should be data, not code
RULE 4.3: Installation vs. Configuration Boundaries

- ❌ NEVER mix package installation and configuration in the same layer
- ❌ NEVER place user-specific configuration in system-level modules
- ✅ ALWAYS install packages at the system-level via `environment.systemPackages`
- ✅ ALWAYS manage user-specific configuration via `home-manager` modules
- ✅ PRINCIPLE: The system provides the tools; the user configures them.

---

## LAW 5: SOURCE INTEGRITY - NIXPKGS-FIRST INSTALLATION

**RULE 5.1: Nixpkgs Priority Mandate**
- ❌ **NEVER** use Homebrew for applications available in nixpkgs
- ❌ **NEVER** use external package managers when Nix equivalents exist
- ❌ **NEVER** mix installation sources for the same application category
- ✅ **ALWAYS** check nixpkgs availability first before considering alternatives
- ✅ **ALWAYS** prefer nixpkgs for maximum reproducibility and hermetic builds
- ✅ **ALWAYS** document exceptions with clear technical justification

**RULE 5.2: Exception Documentation Requirements**
- ❌ **NEVER** use non-nixpkgs sources without documented justification
- ❌ **NEVER** assume an application "doesn't work" in nixpkgs without testing
- ✅ **ALWAYS** document why nixpkgs installation failed or is unsuitable
- ✅ **ALWAYS** include specific error messages or technical limitations
- ✅ **ALWAYS** revisit exceptions periodically as nixpkgs evolves

**RULE 5.3: Reproducibility Justification**
- ❌ **NEVER** sacrifice reproducibility for convenience
- ❌ **NEVER** use "it's easier" as justification for non-nixpkgs sources
- ✅ **ALWAYS** prioritize hermetic builds over installation simplicity
- ✅ **ALWAYS** ensure configurations work from clean state
- ✅ **PRINCIPLE**: Single source of truth enables reproducible deployments

**RULE 5.4: System Settings Domain Authority**
- ❌ **NEVER** write to `NSGlobalDomain` from any module except `darwin/system-settings`
- ❌ **NEVER** create separate modules for keyboard, trackpad, appearance, or other System Settings panes
- ❌ **NEVER** duplicate NSGlobalDomain keys between nix-darwin and home-manager
- ✅ **ALWAYS** use `darwin.system-settings` for ALL macOS System Settings preferences
- ✅ **ALWAYS** organize settings by System Settings pane (Keyboard, Dock, Appearance, etc.)
- ✅ **PRINCIPLE**: Single source of truth for NSGlobalDomain prevents cache corruption and blank System Settings panes

**RULE 5.4 Examples:**

**❌ WRONG - Multiple Modules Writing to NSGlobalDomain:**
```nix
# modules/darwin/keyboard/default.nix
system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;

# modules/darwin/trackpad/default.nix
system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = false;

# This causes: Blank System Settings panes, cache corruption
```

**❌ WRONG - Home Manager Writing to NSGlobalDomain:**
```nix
# modules/home/macos/keybindings.nix
targets.darwin.defaults.NSGlobalDomain = {
  KeyRepeat = 2;
  InitialKeyRepeat = 15;
};

# This causes: Conflicts with nix-darwin, cache corruption
```

**✅ CORRECT - Single Module with Pane Organization:**
```nix
# modules/darwin/system-settings/default.nix
system.defaults.NSGlobalDomain = {
  # Keyboard pane settings
  "com.apple.keyboard.fnState" = cfg.keyboard.enableFnKeys;
  KeyRepeat = cfg.keyboard.keyRepeat;
  InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
  
  # Trackpad pane settings
  AppleEnableSwipeNavigateWithScrolls = cfg.trackpad.swipeNavigation;
  "com.apple.trackpad.scaling" = cfg.trackpad.trackpadSpeed;
  
  # Appearance pane settings
  AppleInterfaceStyleSwitchesAutomatically = cfg.appearance.automaticSwitchAppearance;
  
  # All in ONE place, no conflicts, organized by pane
};
```

**System Settings Pane Organization:**

The `darwin.system-settings` module implements a UNIFIED config block that prevents NSGlobalDomain conflicts. All pane settings are organized to match macOS System Settings UI:

```nix
darwin.system-settings = {
  enable = true;
  
  # Maps to System Settings > Keyboard
  keyboard = {
    keyRepeat = 2;
    initialKeyRepeat = 15;
    pressAndHoldEnabled = false;
    remapCapsLockToControl = true;
    enableFnKeys = true;
  };
  
  # Maps to System Settings > Desktop & Dock
  desktopAndDock = {
    dock = {
      autohide = true;
      autohideDelay = 0.0;
      orientation = "bottom";
      tileSize = 48;
      showRecents = false;
    };
    missionControl = {
      separateSpaces = true;
      exposeAnimation = 0.1;
    };
    hotCorners = {
      topLeft = null;
      topRight = "Mission Control";
      bottomLeft = null;
      bottomRight = null;
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
    trackpadSpeed = 0.6875;
  };
  
  # Maps to System Settings > General (+ Finder settings)
  general = {
    textInput = {
      disableAutomaticCapitalization = false;
      disableAutomaticSpellingCorrection = false;
    };
    finder = {
      showAllExtensions = true;
      showPathbar = true;
      defaultView = "list";
    };
  };
};
```

**Why This Matters:**
- macOS stores many settings in `NSGlobalDomain` (the global preferences domain)
- Multiple modules writing to `NSGlobalDomain` causes cache corruption via cfprefsd
- Results in blank System Settings panes and unpredictable behavior
- `system-settings` implements a SINGLE, UNIFIED config block to prevent conflicts
- Organization matches macOS UI for intuitive, maintainable configuration

**Historical Context:**
- Previously had separate `keyboard` module writing to `NSGlobalDomain`
- Caused conflicts with other modules also writing to `NSGlobalDomain`  
- Resolved by merging ALL System Settings into unified `system-settings` module
- See `docs/reference/darwin-modules-conflicts.md` for complete analysis and resolution

**Current Documented Exceptions:**

#### **Unfree Packages (allowUnfreePredicate)**
- **Warp Terminal**: Successfully installed from nixpkgs via Home Manager (unfree)
  - **Status**: ✅ Working via nixpkgs `warp-terminal` package
  - **Location**: Home Manager user packages (WARP-compliant per RULE 4.3)
  - **Version strategy**: nixpkgs may lag ~1 week; acceptable due to built-in auto-update
  - **Detail**: See `docs/reference/exceptions.md` for complete technical justification
- **Raycast**: Essential productivity launcher, no suitable FOSS alternative
  - **Detail**: See `docs/reference/exceptions.md`
- **gh-copilot**: GitHub Copilot CLI, official GitHub tool
  - **Detail**: See `docs/reference/exceptions.md`

#### **Homebrew Casks**
- **Claude Desktop**: Not available in nixpkgs as of 2025-10-06
  - **Alternative analysis**:
    - **nixpkgs status**: No claude-desktop package exists in nixpkgs
    - **upstream availability**: Official Anthropic releases via direct download and Homebrew cask only
    - **packaging complexity**: Electron app with frequent updates, no community packaging effort
    - **technical justification**: Homebrew cask `claude` provides official, maintained distribution
    - **integration approach**: System-level installation via nix-homebrew + user-level MCP configuration via Home Manager
    - **reproducibility maintained**: MCP servers use nixpkgs/mcp-servers-nix, only the GUI client uses Homebrew
    - **review schedule**: Re-evaluate when/if nixpkgs gains claude-desktop package
- Future exceptions require similar detailed justification

---

## LAW 6: FILE SYSTEM AND DIRECTORY RULES

**RULE 6.1: Repository Boundary Enforcement**
- ❌ **NEVER** modify files outside `/Users/jrudnik/nix-config/`
- ❌ **NEVER** create symlinks or files in user home directory manually
- ❌ **NEVER** touch system directories outside nix-darwin mechanisms
- ✅ **ONLY** work within the nix-config repository boundaries
- ✅ **ONLY** let nix-darwin and home-manager manage external files

**RULE 6.2: Documentation Synchronization**
- ❌ **NEVER** write documentation for non-existent code
- ❌ **NEVER** leave outdated documentation after changes
- ✅ **ALWAYS** update documentation when making changes
- ✅ **ALWAYS** ensure code and documentation stay in sync

**RULE 6.3: Module Organization Standards**
```
✅ CORRECT MODULE STRUCTURE:
modules/
├── darwin/              # System modules (nix-darwin)
├── home/                # User modules (home-manager)
└── nixos/               # Linux modules (future)

❌ NEVER mix concerns across these boundaries
```

---

## LAW 7: WORKFLOW AND PROCESS ADHERENCE

**RULE 7.1: Mandatory Documentation Reading**
- ❌ **NEVER** make changes without reading documentation first
- ✅ ALWAYS review these files before making changes:
  - `docs/reference/architecture.md` - System architecture and design philosophy
  - `docs/guides/modular-architecture.md` - Advanced module patterns
  - `docs/guides/workflow.md` - Complete development workflow
  - `docs/reference/module-options.md` - Available module options reference
  - `docs/getting-started.md` - Setup and configuration guide

**RULE 7.2: Git and Version Control Standards**
- ❌ **NEVER** commit broken configurations
- ❌ **NEVER** push without testing changes locally
- ✅ **ALWAYS** test with `./scripts/build.sh build` before committing
- ✅ **ALWAYS** use descriptive commit messages following conventional commits
- ✅ **ALWAYS** commit working state before making next change

**RULE 7.3: Simplicity Enforcement**
- ❌ **NEVER** create a module when direct configuration suffices
- ❌ **NEVER** use conditionals when simple declarations work
- ✅ **ALWAYS** choose the simplest solution that works
- ✅ **PRINCIPLE**: The best code is the code you don't write

---

## LAW 8: PURE FUNCTIONAL CONFIGURATION

**RULE 8.1: No Side Effects**
- ❌ **NEVER** create configurations that depend on external state
- ❌ **NEVER** assume files or commands exist outside nix store
- ✅ **ALWAYS** make configuration completely hermetic and reproducible
- ✅ **ALWAYS** ensure configuration works from clean state

**RULE 8.2: Declarative State Management**
- ❌ **NEVER** manage state imperatively
- ❌ **NEVER** create scripts that modify configuration outside build process
- ✅ **ALWAYS** let nix-darwin and home-manager manage all state
- ✅ **ALWAYS** use proper nix mechanisms for system changes

**RULE 8.3: Reproducibility Guarantee**
- ❌ **NEVER** create configurations that work only on your machine
- ❌ **NEVER** hardcode paths or assume specific system state
- ✅ **ALWAYS** ensure configurations work on fresh installations
- ✅ **ALWAYS** test reproducibility across different machines when possible

---

## LAW 9: INTELLIGENT HOME-MANAGER CONFIGURATION

**RULE 9.1: Research Before Implementing**
- ❌ **NEVER** assume a single configuration method fits all scenarios. Different tools are best managed in different ways.
- ✅ **ALWAYS** use MCP servers (e.g., `search_code` on GitHub, web searches) to research best practices for managing a specific application with Home Manager before writing new code.
- ✅ **PRINCIPLE**: Leverage community knowledge. Others have likely already solved the problem.

**RULE 9.2: Choose the Right Tool for the Job**
- ❌ **NEVER** force a configuration method where it doesn't fit (e.g., templating a complex binary file).
- ✅ **ALWAYS** select the appropriate Home Manager feature for the task. The table below provides a general guide:

| Method                               | Best For...                                                                 | Example Use Case                                                        |
| ------------------------------------ | --------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `home.file`                          | Managing static, self-contained dotfiles or simple string-based configs.    | A static `.vimrc` file, a simple `starship.toml` written as a string.     |
| Structured Formats (`pkgs.formats`)  | Generating structured data like JSON, TOML, or YAML from native Nix code.   | Configuring alacritty (YAML), helix (TOML), or VS Code `settings.json`. |
| Activation Scripts (`home.activation`) | Running one-time setup commands or imperative actions after a build.        | Initializing a `gpg` key, cloning a git repo, creating a database schema. |
| Environment Variables (`home.sessionVariables`) | Configuring tools that read their settings from the environment.                | Setting `EDITOR`, `LANG`, API keys, or modifying your `$PATH`.          |
| Templating (`pkgs.substituteAll`)    | Populating mostly-static config files with a few dynamic values from Nix.   | A `.gitconfig` with your name/email, a script pointing to a Nix-managed path. |

---

## COMMON VIOLATIONS (DO NOT DO THESE)

### ❌ VIOLATION 1: Creating Custom Module for Nixpkgs Program

**BAD: Custom wrapper for program that nixpkgs provides**
```nix
# modules/home/myeditor/default.nix
{ config, lib, pkgs, ... }:

{
  options.home.myeditor.enable = lib.mkEnableOption "My Editor";
  
  config = lib.mkIf config.home.myeditor.enable {
    home.packages = [ pkgs.neovim ];
    home.file.".config/nvim/init.vim".text = "set number";
  };
}
```

**GOOD: Use nixpkgs module directly**
```nix
# home/jrudnik/home.nix
programs.neovim = {
  enable = true;
  extraConfig = "set number";
};
```

---

### ❌ VIOLATION 2: Writing to NSGlobalDomain Outside system-settings

**BAD: Writing to NSGlobalDomain from home-manager**
```nix
# modules/home/macos/keybindings.nix
targets.darwin.defaults.NSGlobalDomain = {
  KeyRepeat = 2;
  InitialKeyRepeat = 15;
};
```

**BAD: Writing to NSGlobalDomain from separate darwin module**
```nix
# modules/darwin/keyboard/default.nix
system.defaults.NSGlobalDomain = {
  "com.apple.keyboard.fnState" = true;
};
```

**GOOD: ALL NSGlobalDomain writes in system-settings**
```nix
# host/parsley/configuration.nix
darwin.system-settings = {
  enable = true;
  keyboard = {
    keyRepeat = 2;
    initialKeyRepeat = 15;
    enableFnKeys = true;
  };
};
```

---

### ❌ VIOLATION 3: Mixing Installation and Configuration

**BAD: Configuring a tool in the same place it is installed**
```nix
# hosts/parsley/configuration.nix
programs.git = {
  enable = true; # ✅ OK - System-level installation
  userName = "jrudnik"; # ❌ WRONG - User-specific config
  userEmail = "john.rudnik@gmail.com"; # ❌ WRONG - User-specific config
};
```

**GOOD: Separating Installation from Configuration**
```nix
# hosts/parsley/configuration.nix
# Installation is handled by environment.systemPackages or a system-level module

# home/jrudnik/home.nix
# Configuration is handled by home-manager
programs.git = {
  enable = true;
  userName = "jrudnik";
  userEmail = "john.rudnik@gmail.com";
};
```

---

### ❌ VIOLATION 4: Using Homebrew When Nixpkgs Available

**BAD: Homebrew for available packages**
```nix
# hosts/parsley/configuration.nix
homebrew.casks = [
  "warp"  # ❌ WRONG - available in nixpkgs as warp-terminal
];
```

**GOOD: Check nixpkgs first**
```nix
# home/jrudnik/home.nix
home.packages = with pkgs; [
  warp-terminal  # ✅ Available in nixpkgs
];

# Only use Homebrew for truly unavailable packages
# hosts/parsley/configuration.nix
homebrew.casks = [
  "claude"  # ✅ OK - not in nixpkgs, documented exception
];
```

---

### ❌ VIOLATION 5: Complex Logic in Host Config

**BAD: Conditionals and logic in host file**
```nix
# hosts/parsley/configuration.nix
{
  environment.systemPackages = with pkgs; 
    if isDevelopmentMachine then
      [ git neovim nodejs ]
    else
      [ git ];
}
```

**GOOD: Logic in modules, data in host config**
```nix
# modules/darwin/development/default.nix
{ config, lib, pkgs, ... }: {
  options.darwin.development.enable = lib.mkEnableOption "development tools";
  config = lib.mkIf config.darwin.development.enable {
    environment.systemPackages = with pkgs; [ neovim nodejs ];
  };
}

# hosts/parsley/configuration.nix
{
  darwin.development.enable = true;  # Simple boolean flag
}
```

---

### ❌ VIOLATION 6: Manual System Commands

**BAD: Imperative activation script**
```nix
system.activationScripts.setupMyApp = ''
  defaults write com.myapp.preferences setting value
  osascript -e 'tell application "Finder" to restart'
'';
```

**GOOD: Declarative configuration**
```nix
# Use system.defaults for macOS preferences
system.defaults."com.myapp.preferences" = {
  setting = "value";
};

# Finder restarts automatically when system.defaults changes
```

---

## MCP TOOL USAGE PATTERNS FOR AGENTS

**For AI Agents (Claude, GitHub Copilot, etc.) working with this configuration:**

### Pattern 1: Checking Package Availability

**Before creating any custom module, ALWAYS check:**

```bash
# Step 1: Use MCP brave-search or web search
Search: "nixpkgs <package-name>"
Search: "home-manager programs.<package-name>"

# Step 2: Use MCP filesystem to check existing modules
Read: modules/home/
Read: modules/darwin/

# Step 3: Use MCP git to check history
Search git history: "<package-name>"
```

**Example workflow:**
```
User asks: "Add neovim configuration"

Agent thinks:
1. Search nixpkgs: "nixpkgs neovim home-manager"
2. Find: programs.neovim exists in home-manager ✅
3. Decision: Use programs.neovim directly, don't create custom module
4. Read: docs/reference/module-options.md to see if already configured
5. Propose: Enable programs.neovim in home configuration
```

---

### Pattern 2: Understanding Current Architecture

**Before proposing structural changes:**

```bash
# Step 1: Read core documentation
MCP filesystem: Read docs/reference/architecture.md
MCP filesystem: Read docs/guides/modular-architecture.md

# Step 2: Examine current structure
MCP filesystem: List modules/darwin/
MCP filesystem: List modules/home/

# Step 3: Check recent patterns
MCP git: Show recent commits
MCP git: Search for similar features
```

**Example workflow:**
```
User asks: "Add a new system settings option"

Agent thinks:
1. Read: modules/darwin/system-settings/default.nix
2. Understand: Pane-based organization pattern
3. Check: Which pane does this belong to?
4. Verify: No NSGlobalDomain writes outside system-settings
5. Propose: Add option to appropriate pane module
```

---

### Pattern 3: Before Proposing NSGlobalDomain Changes

**CRITICAL: Always verify NSGlobalDomain changes go to system-settings:**

```bash
# Step 1: Check system-settings structure
MCP filesystem: Read modules/darwin/system-settings/default.nix
MCP filesystem: List modules/darwin/system-settings/

# Step 2: Search for existing patterns
MCP git: Search history for "NSGlobalDomain"

# Step 3: Verify no conflicts
MCP filesystem: Search codebase for "NSGlobalDomain"
Ensure: Only system-settings module writes to it
```

**Example workflow:**
```
User asks: "Make keyboard repeat faster"

Agent thinks:
1. Identify: This is a keyboard setting → NSGlobalDomain
2. STOP: Check RULE 5.4 - only system-settings can write
3. Read: modules/darwin/system-settings/keyboard.nix
4. Find: keyRepeat option already exists
5. Propose: Modify darwin.system-settings.keyboard.keyRepeat value
6. NOT: Create new module or write to NSGlobalDomain elsewhere
```

---

### Pattern 4: Validating Changes Before Proposing

**Always validate your proposed changes:**

```bash
# Step 1: Check if module already exists
MCP filesystem: Does modules/home/<tool>/ exist?
MCP brave-search: Does programs.<tool> exist in nixpkgs?

# Step 2: Verify build will succeed
Check: All referenced packages exist in nixpkgs
Check: Syntax is valid Nix
Check: No conflicting options

# Step 3: Confirm with documentation
MCP filesystem: Read docs/reference/module-options.md
Verify: Proposed options follow patterns
```

---

### Available MCP Servers

This configuration includes the following MCP servers for agent use:

- **filesystem**: Read repository files and directory structure
- **git**: Query repository history, commits, and diffs
- **github**: Search issues, PRs, and repositories
- **brave-search**: Web search when needed
- **fetch**: Retrieve web pages and documentation

### Essential Documentation for Agents

**📋 Priority Documents (agents should read these first):**
- **[`docs/reference/architecture.md`](docs/reference/architecture.md)** - System architecture and design philosophy
- **[`docs/guides/modular-architecture.md`](docs/guides/modular-architecture.md)** - Advanced module patterns and examples  
- **[`docs/guides/workflow.md`](docs/guides/workflow.md)** - Complete development workflow guide
- **[`docs/reference/module-options.md`](docs/reference/module-options.md)** - All available module options reference
- **[`docs/getting-started.md`](docs/getting-started.md)** - Setup and configuration guide
- **[`docs/reference/exceptions.md`](docs/reference/exceptions.md)** - Current exceptions to WARP laws with justifications

**🤖 AI Tools Documentation:**
- **[`docs/guides/ai-tools.md`](docs/guides/ai-tools.md)** - Complete AI tools integration guide (Claude, Gemini, Copilot, Fabric)
- **[`docs/reference/mcp.md`](docs/reference/mcp.md)** - MCP (Model Context Protocol) server configuration
- **[`docs/reference/fabric-ai-integration.md`](docs/reference/fabric-ai-integration.md)** - Fabric AI patterns and workflows
- **[`modules/home/ai/patterns/fabric/README.md`](modules/home/ai/patterns/fabric/README.md)** - Custom Fabric patterns reference

**🏷️ Agent Usage Tip**: Use MCP filesystem tools to access these documents directly for the most current information

---

## AGENT PRE-FLIGHT CHECKLIST

Before proposing any changes, verify:

- [ ] **Checked nixpkgs availability**: Searched for `programs.<tool>` or package in nixpkgs
- [ ] **Verified module location**: Confirmed correct placement (darwin/ vs home/)
- [ ] **NSGlobalDomain check**: Ensured no NSGlobalDomain writes outside system-settings
- [ ] **Package boundaries**: GUI apps → environment.systemPackages, CLI tools → home.packages
- [ ] **Read documentation**: Reviewed relevant docs in docs/ directory
- [ ] **MCP tools used**: Used filesystem/git MCP to understand current state
- [ ] **Build plan**: Prepared to test with `./scripts/build.sh build` first
- [ ] **Staged new files**: If new files were created, ensure they are staged with `git add .` before building.
- [ ] **Single logical change**: Change represents one coherent modification
- [ ] **Commit message**: Planned conventional commit format message
- [ ] **No violations**: Double-checked against Common Violations section above

### Example Pre-Flight Check

**Scenario: User asks to add ripgrep configuration**

```
✅ Checked nixpkgs: programs.ripgrep exists in home-manager
✅ Module location: home-manager (user CLI tool)
✅ NSGlobalDomain: No system settings involved
✅ Package boundary: CLI tool → home.packages (but programs.ripgrep handles this)
✅ Read docs: Checked docs/reference/module-options.md
✅ MCP used: Listed modules/home/ to verify no existing ripgrep module
✅ Build plan: Will suggest testing with build script
✅ Single change: Just enabling ripgrep
✅ Commit message: "feat(cli): enable ripgrep with custom config"
✅ No violations: Using programs.ripgrep directly (RULE 2.4 compliant)

Decision: Propose enabling programs.ripgrep in home configuration ✅
```

---

## COMPLIANCE ENFORCEMENT

This is not optional guidance. WARP.md rules are mandatory requirements. Violations will be rejected in code review.

**When in doubt:**
1. Read the relevant LAW in this document
2. Check existing modules for patterns
3. Consult `docs/reference/architecture.md` for philosophy
4. Use MCP tools to understand current implementation
5. Review the Common Violations section above
6. Complete the Pre-Flight Checklist
7. Ask for clarification before proceeding

**Remember**: The goal is not perfection, but consistency, maintainability, and reproducibility. These rules exist to make the configuration easier to understand, modify, and extend over time.

---

*Last Updated: 2025-10-10*  
*Version: 2.2*  
*Changelog: Added Quick Reference, Decision Flowchart, Common Violations, MCP Tool Usage Patterns, Pre-Flight Checklist, and enhanced RULE 5.4 examples for LLM agent effectiveness*
