# WARP.md - MANDATORY CONFIGURATION RULES

**⚠️ CRITICAL: This file contains MANDATORY RULES that must be followed without exception when working with this nix-config repository. These are not suggestions or guidelines - they are hard requirements.**

**🚫 VIOLATIONS WILL BE REJECTED 🚫**

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
- ❌ **NEVER** put Darwin-specific options in NixOS modules or vice versa
- ❌ **NEVER** mix system and user concerns in the same module
- ✅ **ALWAYS** keep `modules/darwin/`, `modules/nixos/`, and `modules/home/` strictly separate
- ✅ **ALWAYS** use the correct module type for the configuration layer

**RULE 2.2: One Module, One Concern**
- ❌ **NEVER** create modules that handle multiple unrelated features
- ❌ **NEVER** exceed ~100 lines per module file without splitting
- ✅ **ALWAYS** name modules by what they do, not by category (good: `docker`, bad: `containers`)
- ✅ **ALWAYS** create focused, single-responsibility modules

**RULE 2.3: Platform Separation Enforcement**
- ❌ **NEVER** use platform conditionals in system modules
- ❌ **NEVER** share code between Darwin and NixOS system modules
- ✅ **ONLY** home modules may use platform detection when necessary
- ✅ **ALWAYS** create separate implementations for different platforms

---

## LAW 3: TYPE SAFETY AND VALIDATION

**RULE 3.1: Strict Type Usage**
- ❌ **NEVER** use `types.str` when more specific types exist
- ❌ **NEVER** create options without type specifications
- ✅ **ALWAYS** use `types.path` for paths, `types.port` for ports, `types.enum` for choices
- ✅ **ALWAYS** use `types.listOf`, `types.attrsOf` for collections

**RULE 3.2: Documentation Requirements**
- ❌ **NEVER** create options without descriptions
- ❌ **NEVER** use generic or unhelpful descriptions
- ✅ **ALWAYS** add meaningful descriptions to every option
- ✅ **ALWAYS** document the impact and usage of each option

**RULE 3.3: Default Value Mandates**
- ❌ **NEVER** create options without sensible defaults
- ❌ **NEVER** force users to configure things they don't care about
- ✅ **ALWAYS** provide working defaults for all options
- ✅ **ALWAYS** make the simple case simple, complex case possible

---

## LAW 4: BUILD AND TEST DISCIPLINE

**RULE 4.1: Incremental Testing Protocol**
- ❌ **NEVER** apply changes without testing builds first
- ❌ **NEVER** make multiple logical changes simultaneously
- ✅ **ALWAYS** run `./scripts/build.sh build` before `./scripts/build.sh switch`
- ✅ **ALWAYS** make one logical change at a time
- ✅ **ALWAYS** commit working configurations before the next change

**RULE 4.2: Configuration Logic Restrictions**
- ❌ **NEVER** put conditionals or logic in host configs
- ❌ **NEVER** use `mkIf` or complex expressions in host configurations
- ✅ **ALWAYS** keep host configs as declarative statements only
- ✅ **ALWAYS** extract logic to modules if needed

**RULE 4.3: Package Management Boundaries**
- ❌ **NEVER** put non-essential packages in `environment.systemPackages`
- ❌ **NEVER** duplicate packages between system and user configuration
- ✅ **ONLY** system packages: essential tools that must be system-wide
- ✅ **ALWAYS** prefer home-manager packages for user applications
- ✅ **RULE OF THUMB**: if you can't explain why it must be system-level, it shouldn't be

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

**Current Documented Exceptions:**
- **Warp Terminal**: nixpkgs installation failed due to [specific technical issues - requires documentation]
- **Claude Desktop**: Not available in nixpkgs as of 2025-10-06. Alternative analysis:
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
- ✅ **ALWAYS** review these files before making changes:
  - `docs/architecture.md` - System architecture and design philosophy
  - `docs/modular-architecture.md` - Advanced module patterns
  - `docs/workflow.md` - Complete development workflow
  - `docs/module-options.md` - Available module options reference
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

## Tool Utilization

Unless certain about how to do something, it's best practice to leverage MCP servers to better formulate an approach.

**📚 Essential Reading Before Making Changes:**
- **[`docs/architecture.md`](docs/architecture.md)** - System architecture and design philosophy
- **[`docs/modular-architecture.md`](docs/modular-architecture.md)** - Advanced module patterns and examples  
- **[`docs/workflow.md`](docs/workflow.md)** - Complete development workflow guide
- **[`docs/module-options.md`](docs/module-options.md)** - All available module options reference
- **[`docs/getting-started.md`](docs/getting-started.md)** - Setup and configuration guide

## Development Commands

### Build and Switch Configuration
```bash
# Test configuration (dry run)
./scripts/build.sh build

# Apply configuration (system changes)
./scripts/build.sh switch

# Validate flake syntax and dependencies
./scripts/build.sh check

# Update all flake inputs
./scripts/build.sh update

# Clean old generations (quick)
./scripts/build.sh clean

# Comprehensive cleanup with options
./scripts/cleanup.sh
```

### Manual Commands
```bash
# Direct nix-darwin commands
darwin-rebuild build --flake ~/nix-config#parsley
sudo darwin-rebuild switch --flake ~/nix-config#parsley

# Standalone home-manager (when needed)
home-manager switch --flake ~/nix-config#jrudnik@parsley

# Check flake directly
cd ~/nix-config && nix flake check
```

### Testing Changes
When modifying configuration:
1. Always run `./scripts/build.sh build` first to test
2. Use `./scripts/build.sh check` to validate flake syntax
3. Only use `switch` after successful build test

## Architecture Overview

This is a **modular Nix configuration** for macOS using nix-darwin and Home Manager. The key architectural principle is **clean separation between system and user configuration** through reusable modules.

### Core Structure
```
~/nix-config/
├── flake.nix              # Main configuration with inputs/outputs
├── hosts/parsley/          # System configuration (65 lines)
├── home/jrudnik/           # User configuration (61 lines) 
├── modules/
│   ├── darwin/            # System modules (10 modules)
│   ├── home/              # User modules (9 modules)
│   ├── ai/                # AI tools modules
│   └── nixos/             # Linux modules (future)
├── overlays/              # Package overlays and modifications
├── scripts/               # Build and cleanup scripts
├── secrets/               # Encrypted secrets (future)
└── docs/                  # Comprehensive documentation
```

### Configuration Philosophy
- **No external frameworks** - Direct nix-darwin + home-manager usage
- **Modular design** - 10 reusable Darwin modules, 9 Home Manager modules
- **Minimal complexity** - 65-line system config, 61-line user config
- **Type-safe options** - All modules use proper NixOS module pattern with options/config
- **Easy scaling** - Add hosts/users without duplication

### Module System
**Darwin modules** (system-level):
- `core` - Essential packages and shell setup
- `security` - Touch ID, user management 
- `nix-settings` - Nix daemon optimization, binary caches
- `system-defaults` - macOS system preferences
- `keyboard` - Keyboard and input configuration
- `homebrew` - Homebrew casks and Mac App Store apps
- `window-manager` - AeroSpace window management (deprecated)
- `theming` - System-wide theming with Stylix
- `fonts` - Font management and Nerd Font installation
- `browser` - Browser configuration and management

**Home modules** (user-level):
- `shell` - Zsh with oh-my-zsh, aliases, configuration
- `development` - Programming languages (Rust, Go, Python), editors
- `git` - Git configuration and settings
- `cli-tools` - Modern CLI tools (eza, bat, ripgrep, fd, zoxide, etc.)
- `window-manager` - AeroSpace window management configuration
- `raycast` - Raycast launcher configuration
- `browser` - Browser configuration (Zen Browser)
- `security` - Security tools (Bitwarden) configuration
- `mcp` - Model Context Protocol servers for Claude Desktop

### Integration Pattern
System and user configurations are **integrated** - nix-darwin manages the Home Manager configuration:

```nix
# System config includes home-manager
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  users.jrudnik = import ./home/jrudnik/home.nix;
};
```

This ensures atomic system+user builds and consistent package versions.

## Configuration Patterns

### Module Usage Pattern
All configurations use the clean module pattern:

```nix
# System config (hosts/parsley/configuration.nix)
darwin = {
  core.enable = true;
  security = {
    enable = true;
    primaryUser = "jrudnik";
    touchIdForSudo = true;
  };
  nix-settings.enable = true;
  system-defaults.enable = true;
};

# User config (home/jrudnik/home.nix)  
home = {
  shell.enable = true;
  development = {
    enable = true;
    languages = { rust = true; go = true; python = true; };
    editor = "micro";
  };
  git = {
    enable = true;
    userName = "jrudnik";
    userEmail = "john.rudnik@gmail.com";
  };
};
```

### Special Arguments Access
All modules receive these arguments automatically:
- `inputs` - Flake inputs (nixpkgs, nix-darwin, home-manager)
- `outputs` - Flake outputs (modules, overlays)
- Standard arguments: `config`, `pkgs`, `lib`

## Adding New Configuration

### New Darwin Module
1. Create `modules/darwin/my-module/default.nix` with options/config pattern
2. Add to `modules/darwin/default.nix` exports
3. Import in host configuration and enable

### New Home Module  
1. Create `modules/home/my-module/default.nix` with options/config pattern
2. Add to `modules/home/default.nix` exports
3. Import in user configuration and enable

### New Host
1. Create `hosts/new-host/configuration.nix`
2. Add to `flake.nix` in `darwinConfigurations`
3. Update scripts if needed for new hostname

### New User
1. Create `home/new-user/home.nix`
2. Add to `flake.nix` in `homeConfigurations`
3. Add to system config's home-manager users

## Common Tasks

### Package Management
- **System packages**: Only essential tools in `modules/darwin/core`
- **User packages**: Development tools in `modules/home/development`
- **Program config**: Use home-manager program modules when available

### System Defaults
macOS system preferences are managed declaratively in `modules/darwin/system-defaults` using nix-darwin's `system.defaults` options.

### Debugging Build Issues
1. Check syntax: `./scripts/build.sh check`
2. Test build: `./scripts/build.sh build` 
3. Check module options: See `docs/module-options.md`
4. Review logs: Build output shows detailed error information

### Application Availability Issues
If applications installed via Nix aren't available after switching:

1. **Restart your shell**: `refresh-env` (alias) or `exec zsh`
2. **Reload configuration**: `reload-path` (alias) or `source ~/.zshrc`
3. **Check PATH**: `echo $PATH` should include `/etc/profiles/per-user/$USER/bin`
4. **Enable debugging**: Set `home.shell.debugEnvironment = true;` in your config
5. **Manual PATH check**: `ls -la /etc/profiles/per-user/$USER/bin/` to verify binaries exist

### Managing Generations
- Quick cleanup: `./scripts/build.sh clean`
- Interactive cleanup: `./scripts/cleanup.sh`
- Aggressive cleanup: `./scripts/cleanup.sh aggressive`
- View generations: `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system`

## Development Guidelines

### Module Development
- Use proper NixOS module pattern with `options` and `config`
- Provide type-safe options with descriptions
- Use `mkEnableOption` for enable flags
- Use `mkIf cfg.enable` for conditional configuration
- Document all options clearly

### Configuration Changes
- Test with `build` before `switch`
- Keep configurations minimal - use module options
- Follow the modular pattern rather than inline configuration
- Check documentation in `docs/` for detailed examples

### File Organization
- System-level changes go in `modules/darwin/`
- User-level changes go in `modules/home/` 
- Host-specific settings in `hosts/hostname/`
- User-specific settings in `home/username/`
- Never duplicate configuration - create reusable modules instead