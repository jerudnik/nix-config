# John's Nix Configuration

> **📚 Documentation:** See [`docs/`](docs/) for comprehensive guides and architectural details

A clean, modular Nix configuration for macOS using nix-darwin and Home Manager. Built with reusable modules following the NixOS module pattern.

**Migration Note:** Evolved from a framework-dependent setup to a pure, modular architecture that's maintainable and scalable.

## Structure

```
~/nix-config/
├── flake.nix                 # Main flake configuration
├── home/
│   └── jrudnik/
│       └── home.nix          # Clean 78-line user config using modules
├── hosts/
│   └── parsley/
│       └── configuration.nix # Clean 81-line system config using modules
├── modules/
│   ├── darwin/              # Reusable Darwin system modules (9 modules)
│   │   ├── core/            # Essential packages & shell
│   │   ├── security/        # Touch ID & user management
│   │   ├── nix-settings/    # Nix daemon & optimization
│   │   ├── system-defaults/ # macOS system preferences
│   │   ├── keyboard/        # Keyboard & input settings
│   │   ├── homebrew/        # Homebrew package management
│   │   ├── window-manager/  # AeroSpace tiling window manager
│   │   ├── theming/         # Stylix theming system
│   │   └── fonts/           # Font configuration
│   ├── home/                # Reusable home-manager modules (5 modules)
│   │   ├── shell/           # Zsh with oh-my-zsh & aliases
│   │   ├── development/     # Dev tools, languages & editors
│   │   ├── git/             # Git configuration
│   │   ├── cli-tools/       # Modern CLI utilities
│   │   ├── window-manager/  # User window manager settings
│   │   └── raycast/         # Raycast launcher configuration
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

- ✅ **Modular Design**: 15 reusable modules with rich options
- ✅ **Significant Simplification**: 100+ line configs → 78-81 lines
- ✅ **Type Safety**: Options with validation and documentation
- ✅ **NixOS Module Pattern**: Advanced community standards
- ✅ **Easy Scaling**: Zero duplication when adding hosts/users
- ✅ **Framework-Free**: Pure nix-darwin + home-manager

## Features

### Modular Architecture
- **14 reusable modules** (9 darwin + 5 home) with rich configuration options
- **NixOS module pattern** with options/config structure
- **Type-safe configuration** with validation and documentation
- **81-line system config** (reduced from 100+ lines)
- **78-line home config** (reduced from 100+ lines)
- **Easy to extend** - add hosts/users without duplication

### System (nix-darwin)
- Touch ID for sudo authentication
- Sensible macOS defaults (Dock, Finder, Global)
- Nix daemon optimization and binary caches
- Automatic garbage collection and store optimization
- AeroSpace tiling window manager with Alt-based keybindings
- Stylix theming system with Gruvbox Material theme
- Homebrew cask integration for GUI applications
- Font management with iA Writer and Charter fonts

### Home Manager
- Zsh with oh-my-zsh and intelligent aliases
- Git configuration with sensible defaults
- Development environment (Rust, Go, Python) with optional Emacs
- Modern CLI tools (eza, bat, ripgrep, fd, fzf, starship)
- System monitor (btop) with beautiful Stylix theming
- Raycast launcher integration (apps auto-discovered)
- Alacritty terminal with automatic theming

## Modular Configuration Examples

### System Configuration (81 lines)
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
  keyboard.enable = true;
  homebrew.casks = [ "warp" ];
  window-manager.enable = true;
  
  theming = {
    enable = true;
    colorScheme = "gruvbox-material-dark-medium";
  };
  
  fonts.enable = true;
};
```

### Home Configuration (78 lines)
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
    emacs = true;  # Optional: Excellent Stylix theming!
  };
  
  cli-tools = {
    enable = true;
    systemMonitor = "btop";  # Beautiful Stylix theming
  };
  
  git = {
    enable = true;
    userName = "jrudnik";
    userEmail = "john.rudnik@gmail.com";
  };
  
  # App organization handled automatically:
  # - Home Manager apps: ~/Applications/Home Manager Apps
  # - System apps: /Applications/Nix Apps
  # - Raycast discovers all apps automatically
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
