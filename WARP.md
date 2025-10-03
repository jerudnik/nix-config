# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

# Project Rules

## Core Principles

1. One module, one concern

- Each module should do exactly one thing
- If a module file exceeds ~100 lines, consider splitting it
- Name modules by what they do, not by category (good: docker, bad: containers)


2. System packages stay minimal

- Only put in environment.systemPackages what absolutely must be system-wide
- When in doubt, use home-manager packages
- Rule of thumb: if you can't explain why it must be system-level, it shouldn't be


3. Provide good defaults, allow overrides

- Every module option should have a sensible default
- Users shouldn't have to configure anything they don't care about
- Make the simple case simple, make the complex case possible


4. Use types for validation

- Never use types.str when there's a more specific type (types.path, types.port, types.enum)
- Use types.listOf, types.attrsOf for collections
- Add descriptions to every option



## Structural Rules

1. Avoid conditionals in host configs

- Host configs should be declarative statements, not logic
- Logic belongs in modules, configuration belongs in hosts
- If you find yourself writing if or mkIf in a host config, extract it to a module


2. Test incrementally

- Always run ./scripts/build.sh build before ./scripts/build.sh switch
- Make one logical change at a time
- Commit working configurations before making the next change


3. Platform separation is sacred

- Never put Darwin-specific options in NixOS modules or vice versa
- Keep modules/darwin/, modules/nixos/, and modules/home/ strictly separate
- Home modules can use platform detection, but system modules should not


4. Documentation follows code

- Every module option needs a description
- Update README.md when you add major features
- Don't write documentation for code that doesn't exist yet


5. Simplicity is the goal

- If you can accomplish something without a module, don't make a module
- If you can accomplish something without conditionals, don't use conditionals
- The best code is the code you don't write

## Tool Utilization

Unless certain about how to do something, it's best practice to leverage MCP servers to better formulate an approach.

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
├── hosts/parsley/          # System configuration (38 lines)
├── home/jrudnik/           # User configuration (51 lines) 
├── modules/
│   ├── darwin/            # System modules (7 modules)
│   └── home/              # User modules (3 modules)
├── scripts/               # Build and cleanup scripts
└── docs/                  # Comprehensive documentation
```

### Configuration Philosophy
- **No external frameworks** - Direct nix-darwin + home-manager usage
- **Modular design** - 7 reusable Darwin modules, 3 Home Manager modules
- **Minimal complexity** - 38-line system config, 51-line user config
- **Type-safe options** - All modules use proper NixOS module pattern with options/config
- **Easy scaling** - Add hosts/users without duplication

### Module System
**Darwin modules** (system-level):
- `core` - Essential packages and shell setup
- `security` - Touch ID, user management 
- `nix-settings` - Nix daemon optimization, binary caches
- `system-defaults` - macOS system preferences

**Home modules** (user-level):
- `shell` - Zsh with oh-my-zsh, aliases, configuration
- `development` - Programming languages (Rust, Go, Python), editors
- `git` - Git configuration and settings

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