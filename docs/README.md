# Nix Configuration

A declarative, modular system configuration for macOS using **Nix Flakes**, **nix-darwin**, and **Home Manager**. This configuration manages both system-level settings and user environments with a focus on simplicity, maintainability, and reproducibility.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/nix-config.git ~/nix-config
cd ~/nix-config

# Build and apply configuration
./scripts/build.sh switch
```

## Repository Structure

```
nix-config/
├── flake.nix              # Flake entry point and outputs
├── flake.lock             # Locked dependency versions
├── lib/                   # Utility functions
├── modules/
│   ├── darwin/            # Reusable Darwin system modules (7 modules)
│   │   ├── core/          # Essential system packages and shell
│   │   ├── security/      # Touch ID, user management, sudo
│   │   ├── nix-settings/  # Nix daemon and binary caches
│   │   ├── system-settings/ # macOS System Settings (pane-based)
│   │   ├── homebrew/      # Homebrew cask management
│   │   ├── theming/       # Stylix system-wide theming
│   │   └── fonts/         # Font installation and management
│   ├── home/              # Reusable home-manager modules (8 modules)
│   │   ├── shell/         # Zsh configuration and aliases
│   │   ├── development/   # Development environment and tools
│   │   ├── git/           # Git configuration
│   │   ├── cli-tools/     # Modern CLI utilities (eza, bat, etc.)
│   │   ├── starship/      # Starship cross-shell prompt
│   │   ├── window-manager/ # AeroSpace tiling window manager
│   │   ├── security/      # Bitwarden password management
│   │   └── ai/            # AI tools (Fabric, Claude, Gemini, Copilot)
│   └── nixos/             # Future NixOS modules (empty)
├── hosts/
│   └── parsley/           # Machine-specific configuration
│       └── configuration.nix
├── home/
│   └── jrudnik/           # User-specific home configuration
│       └── home.nix
├── docs/                  # Comprehensive documentation
└── scripts/               # Build and maintenance scripts
```

## Features

### Modular Architecture
- **15 reusable modules** (7 darwin + 8 home) with rich configuration options
- **NixOS module pattern** with options/config structure and type safety
- **81-line system config, 78-line home config** (reduced from 100+ lines each)
- **Easy to extend** - add hosts/users without duplication

### System (nix-darwin)
- Touch ID for sudo authentication
- **Pane-based System Settings** - organized by macOS System Settings panes (Keyboard, Desktop & Dock, Appearance, Trackpad, General)
- **Unified NSGlobalDomain management** - single source of truth preventing preference conflicts
- Keyboard remapping (Caps Lock → Control/Escape) with configurable key repeat
- Dock configuration with hot corners, auto-hide, and magnification
- Nix daemon optimization with binary caches (Cachix) and automatic garbage collection
- **Stylix theming system** with automatic light/dark switching and multiple color schemes
- Homebrew cask integration for GUI applications
- Font management with Nerd Fonts, iA Writer, and Charter

### Home Manager
- Zsh with oh-my-zsh and intelligent aliases
- Git configuration with sensible defaults and customizable aliases
- Development environment (Rust, Go, Python, Node.js) with optional Neovim
- Modern CLI tools (eza, bat, ripgrep, fd, fzf, atuin) with shell integration
- Starship cross-shell prompt with multiple themes
- System monitor (btop/htop) with beautiful Stylix theming
- AeroSpace tiling window manager with declarative keybindings
- Bitwarden CLI integration for password management
- AI-powered tools (Fabric patterns, Claude Desktop + MCP, Gemini, GitHub Copilot)

## Why System Settings is Pane-Based

The `darwin.system-settings` module is organized by macOS System Settings panes (Keyboard, Desktop & Dock, etc.) to prevent NSGlobalDomain conflicts. When multiple modules write to this global preferences file independently, they cause cache corruption resulting in blank System Settings panes. The pane-based design ensures all NSGlobalDomain writes happen in one unified config block. See [docs/reference/darwin-modules-conflicts.md](reference/darwin-modules-conflicts.md) for full technical details.

## Modular Configuration Examples

### System Configuration (81 lines)
```nix
# hosts/parsley/configuration.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Module definitions from flake
  ];

  darwin = {
    # Essential system foundation
    core.enable = true;
    
    # Touch ID and user management
    security = {
      enable = true;
      primaryUser = "jrudnik";
      touchIdForSudo = true;
    };
    
    # Nix daemon and binary caches
    nix-settings.enable = true;
    
    # Pane-based System Settings (matches macOS UI organization)
    system-settings = {
      enable = true;
      
      # Desktop & Dock pane
      desktopAndDock = {
        dock = {
          autohide = true;
          autohideDelay = 0.0;        # Instant response
          autohideTime = 0.15;        # Fast animation  
          orientation = "bottom";
          magnification = true;
          tileSize = 45;
          largeSize = 70;
        };
        missionControl = {
          separateSpaces = true;      # Better multi-monitor
        };
        hotCorners = {
          topRight = 11;              # Launchpad
          bottomRight = 2;            # Mission Control
        };
      };
      
      # Keyboard pane (includes remapping and key repeat)
      keyboard = {
        keyRepeat = 2;                # Fast key repeat
        initialKeyRepeat = 15;
        remapCapsLockToControl = true;
        enableFnKeys = true;          # F1-F12 as function keys
      };
      
      # Appearance pane
      appearance = {
        automaticSwitchAppearance = true;
      };
      
      # Trackpad pane
      trackpad = {
        naturalScrolling = false;
      };
      
      # General pane (includes Finder)
      general = {
        textInput = {
          disableAutomaticCapitalization = true;
          disableAutomaticSpellingCorrection = true;
        };
        finder = {
          showAllExtensions = true;
          showPathbar = true;
          defaultViewStyle = "column";
        };
      };
    };
    
    # Homebrew casks for GUI apps
    homebrew.casks = [ "claude" "warp" "zen-browser" ];
    
    # System-wide theming with auto light/dark switching
    theming = {
      enable = true;
      colorScheme = "gruvbox-material-dark-medium";
      polarity = "either";          # Auto light/dark switching
      autoSwitch = {
        enable = true;
        lightScheme = "gruvbox-material-light-medium";
        darkScheme = "gruvbox-material-dark-medium";
      };
    };
    
    # Font management
    fonts.enable = true;
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # System state version
  system.stateVersion = 5;
}
```

### Home Configuration (78 lines)
```nix
# home/jrudnik/home.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Module definitions from flake
  ];

  home = {
    # Zsh with oh-my-zsh and aliases
    shell = {
      enable = true;
      aliases.deploy = "cd ~/projects && ./deploy.sh";
    };
    
    # Development environment with language tools
    development = {
      enable = true;
      languages = { 
        rust = true; 
        go = true; 
        python = true; 
      };
      editor = "micro";
      neovim = true;              # Optional: Excellent Stylix theming
    };
    
    # Modern CLI tools with shell integration
    cli-tools = {
      enable = true;
      systemMonitor = "btop";     # Beautiful Stylix theming
      shellEnhancements.atuin = true;  # Magical shell history
    };
    
    # Git configuration
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
      defaultBranch = "main";
    };
    
    # Starship cross-shell prompt
    starship = {
      enable = true;
      theme = "gruvbox-rainbow";
      showLanguages = [ "nodejs" "rust" "golang" "python" "nix_shell" ];
      showSystemInfo = true;
    };
    
    # AeroSpace tiling window manager
    window-manager = {
      enable = true;
      keybindings = {
        terminal = "Warp";
        browser = "Zen Browser";
        passwordManager = "Bitwarden";
      };
    };
    
    # Security and password management
    security.bitwarden.enable = true;
    
    # AI-powered CLI tools
    ai.fabric.enable = true;
  };
  
  # Home Manager state version
  home.stateVersion = "24.11";
}
```

## Build Commands

### Using Build Script (Recommended)

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

> **Note:** All scripts are wrappers around `darwin-rebuild`. See `./scripts/build.sh` for implementation details.

## Extending the Configuration

- **New modules:** Create in `modules/{darwin,home}/`, add to `default.nix`, import in host/home config
- **New hosts:** Create in `hosts/`, add to `flake.nix` outputs
- **New users:** Create in `home/`, add to host's `home-manager.users`

See [guides/workflow.md](guides/workflow.md) for detailed instructions.

## Troubleshooting

- **General Issues** - See [guides/workflow.md#troubleshooting](guides/workflow.md#troubleshooting) for build and configuration problems

## Documentation

- **[Getting Started](getting-started.md)** - A guide to getting up and running with this configuration.

### Guides

- **[AI Tools](guides/ai-tools.md)** - AI development environment setup
- **[Modular Architecture](guides/modular-architecture.md)** - Module patterns and best practices
- **[Workflow](guides/workflow.md)** - Build processes and troubleshooting

### Reference

- **[Architecture Overview](reference/architecture.md)** - System design and philosophy
- **[Darwin Modules Conflicts](reference/darwin-modules-conflicts.md)** - Technical details on NSGlobalDomain conflicts
- **[Exceptions](reference/exceptions.md)** - Exception handling framework
- **[Fabric AI Integration](reference/fabric-ai-integration.md)** - Fabric AI integration details
- **[MCP](reference/mcp.md)** - MCP server integration for Claude Desktop
- **[Module Options](reference/module-options.md)** - Complete API documentation
- **[Quick Reference](reference/quick-reference.md)** - Quick commands and patterns

### Archive

- **[Archived Documentation](archive/README.md)** - Historical and migration-related documentation.

## Design Principles

1. **Single Source of Truth** - One place for each configuration concern (e.g., all NSGlobalDomain writes in `system-settings`)
2. **Zero Duplication** - Scale to multiple hosts/users without copying code
3. **Declarative & Type-Safe** - Rich options with validation

See [reference/architecture.md](reference/architecture.md) and [WARP.md](WARP.md) for complete architectural philosophy.

## License

MIT License - See [LICENSE](LICENSE) for details.
