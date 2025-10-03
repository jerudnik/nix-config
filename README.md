# John's Nix Configuration

> **📚 Documentation:** See [`docs/`](docs/) for daily-use guides • [`docs/deep-dive/`](docs/deep-dive/) for architectural details

A clean, modular Nix configuration for macOS using nix-darwin and Home Manager. Built with reusable modules following the NixOS module pattern.

**Migration Note:** Evolved from a framework-dependent setup to a pure, modular architecture that's maintainable and scalable.

## Structure

```
~/nix-config/
├── flake.nix                 # Main flake configuration
├── home/
│   └── jrudnik/
│       └── home.nix          # Clean 51-line user config using modules
├── hosts/
│   └── parsley/
│       └── configuration.nix # Clean 38-line system config using modules
├── modules/
│   ├── darwin/              # Reusable Darwin system modules
│   │   ├── core/            # Essential packages & shell
│   │   ├── security/        # Touch ID & user management
│   │   ├── nix-settings/    # Nix daemon & optimization
│   │   └── system-defaults/ # macOS system preferences
│   ├── home/                # Reusable home-manager modules
│   │   ├── shell/           # Zsh with oh-my-zsh & aliases
│   │   ├── development/     # Dev tools & languages
│   │   └── git/             # Git configuration
│   └── nixos/               # NixOS modules (future)
├── scripts/
│   ├── build.sh            # Build/switch/check script
│   └── cleanup.sh          # System cleanup script
└── docs/                    # Comprehensive documentation
```

## Quick Start

1. **Build configuration (test):**
   ```bash
   ./scripts/build.sh build
   ```

2. **Apply configuration:**
   ```bash
   ./scripts/build.sh switch
   ```

3. **Check configuration:**
   ```bash
   ./scripts/build.sh check
   ```

4. **Update flake inputs:**
   ```bash
   ./scripts/build.sh update
   ```

5. **Clean old generations:**
   ```bash
   ./scripts/build.sh clean
   
   # Or for comprehensive cleanup
   ./scripts/cleanup.sh
   ```

## Manual Commands

- **Build:** `darwin-rebuild build --flake ~/nix-config`
- **Switch:** `darwin-rebuild switch --flake ~/nix-config`

## Architectural Evolution

This configuration evolved from framework-dependent to advanced modular architecture:

- ✅ **Modular Design**: 7 reusable modules with rich options
- ✅ **Massive Simplification**: 100+ line configs → 38-51 lines
- ✅ **Type Safety**: Options with validation and documentation
- ✅ **NixOS Module Pattern**: Advanced community standards
- ✅ **Easy Scaling**: Zero duplication when adding hosts/users
- ✅ **Framework-Free**: Pure nix-darwin + home-manager

## Features

### Modular Architecture
- **7 reusable modules** with rich configuration options
- **NixOS module pattern** with options/config structure
- **Type-safe configuration** with validation and documentation
- **38-line system config** (reduced from 100+ lines)
- **51-line home config** (reduced from 100+ lines)
- **Easy to extend** - add hosts/users without duplication

### System (nix-darwin)
- Touch ID for sudo authentication
- Sensible macOS defaults (Dock, Finder, Global)
- Nix daemon optimization and binary caches
- Automatic garbage collection and store optimization

### Home Manager
- Zsh with oh-my-zsh and intelligent aliases
- Git configuration with sensible defaults
- Development environment (Rust, Go, Python)
- Micro text editor and essential utilities

## Modular Configuration Examples

### System Configuration (38 lines)
```nix
# hosts/parsley/configuration.nix
darwin = {
  core.enable = true;
  
  security = {
    enable = true;
    primaryUser = "jrudnik";
  };
  
  nix-settings.enable = true;
  system-defaults.enable = true;
};
```

### Home Configuration (51 lines)
```nix
# home/jrudnik/home.nix
home = {
  shell = {
    enable = true;
    aliases.deploy = "cd ~/projects && ./deploy.sh";
  };
  
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

## Adding Configuration

### New Darwin Module
1. Create `modules/darwin/my-module/default.nix`
2. Add to `modules/darwin/default.nix`
3. Import in `hosts/parsley/configuration.nix`

### New Home Manager Module
1. Create `modules/home/my-module/default.nix` 
2. Add to `modules/home/default.nix`
3. Import in `home/jrudnik/home.nix`

### New Host
1. Create `hosts/new-host/configuration.nix`
2. Add to `flake.nix` in `darwinConfigurations`

### New User
1. Create `home/new-user/home.nix`
2. Add to system config's home-manager.users
