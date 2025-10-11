# Nix Configuration Architecture

A clean, modular approach to macOS system configuration using nix-darwin and Home Manager.

## Overview

This configuration system takes a **community-standard approach** to managing macOS environments with Nix. It uses established patterns (nix-darwin for system configuration, Home Manager for user configuration) while keeping everything explicit, maintainable, and easy to understand.

### Core Principles

1. **Separation of Concerns**: Clear distinction between system-level and user-level configuration
2. **Minimal Abstraction**: No custom frameworks – just standard Nix, nix-darwin, and Home Manager
3. **Modularity**: Reusable modules with well-defined options and defaults
4. **Explicitness**: Configuration files are transparent and self-documenting
5. **Maintainability**: Easy to modify, extend, and understand months or years later

## Directory Structure

```
nix-config/
├── flake.nix               # Flake definition (inputs/outputs)
├── hosts/                  # Per-machine configurations
│   └── parsley/           # Configuration for "parsley" host
│       └── configuration.nix
├── home/                   # Per-user configurations
│   └── jrudnik/           # Configuration for "jrudnik" user
│       └── home.nix
├── modules/                # Reusable modules
│   ├── darwin/            # macOS system modules (7 modules)
│   ├── home/              # User environment modules (9 modules)
│   └── nixos/             # Linux modules (future)
├── overlays/              # Package customizations
├── lib/                   # Helper functions
└── scripts/               # Build and utility scripts
```

## Configuration Layers

This system is organized into three distinct layers, each with specific responsibilities:

### Flake Layer

**File**: `flake.nix`

**Responsibilities:**
- Define inputs (nixpkgs, nix-darwin, home-manager)
- Export configurations for each host
- Export reusable modules and overlays
- Provide `specialArgs` for dependency injection

**Key pattern:**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... } @ inputs:
    let
      system = "aarch64-darwin";
      specialArgs = { inherit inputs outputs; };
    in {
      darwinConfigurations = {
        parsley = nix-darwin.lib.darwinSystem {
          inherit system specialArgs;
          modules = [ ./hosts/parsley/configuration.nix ];
        };
      };
    };
}
```

### System Configuration Layer

**File**: `hosts/parsley/configuration.nix`

**Responsibilities:**
- System-wide settings (security, defaults)
- System packages (minimal set)
- User account definitions
- Nix daemon configuration
- Home Manager integration

**Key pattern:**
```nix
{ config, pkgs, lib, inputs, outputs, ... }: {
  # System identity
  networking.hostName = "parsley";
  system.stateVersion = 5;

  # Import modules
  imports = [
    inputs.home-manager.darwinModules.home-manager
    # Custom modules automatically available
  ];

  # Enable custom darwin modules
  darwin = {
    core.enable = true;
    security.enable = true;
    # ...
  };

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    users.jrudnik = import ../../home/jrudnik/home.nix;
  };
}
```

### Home Configuration Layer

**File**: `home/jrudnik/home.nix`

**Responsibilities:**
- User-specific packages and programs
- Shell configuration and aliases
- Development environment setup
- Personal application settings
- Dotfiles and user preferences

**Key pattern:**
```nix
{ config, pkgs, lib, inputs, outputs, ... }: {
  # Home Manager needs these
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik"; 
    stateVersion = "25.05";
  };
  
  # Program configurations
  programs.git = { ... };
  programs.zsh = { ... };
  
  # User packages
  home.packages = with pkgs; [ ... ];
}
```

### Module System

The module system provides reusable functionality:

**Module Structure:**
```nix
# modules/darwin/my-module/default.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my-module;
in {
  options.my-module = {
    enable = mkEnableOption "My custom module";
    setting = mkOption {
      type = types.str;
      default = "default";
      description = "Module setting";
    };
  };

  config = mkIf cfg.enable {
    # Implementation
  };
}
```

**Module Categories:**
- **darwin/** (7 modules): macOS system modules (nix-darwin)
  - core, security, nix-settings, system-settings, homebrew, theming, fonts
- **home/** (9 modules): User environment modules (home-manager)
  - shell, development, git, cli-tools, window-manager, security, mcp, starship, ai
- **nixos/**: Linux system modules (future compatibility)

## Data Flow

```
flake.nix
    ↓
specialArgs (inputs, outputs)
    ↓
┌─────────────────────┬─────────────────────┐
│   System Config     │    Home Config      │
│  (nix-darwin)      │  (home-manager)    │
│                     │                     │
│ • System defaults   │ • User packages     │
│ • Security          │ • Shell config      │
│ • User accounts     │ • Development env   │
│ • Global packages   │ • Personal settings │
└─────────────────────┴─────────────────────┘
    ↓                        ↓
System Generation       Home Generation
```

## Configuration Inheritance

### Argument Passing

```nix
# flake.nix
specialArgs = {
  inherit inputs outputs;
};

# Passed to all modules automatically
darwinSystem {
  inherit system specialArgs;
  modules = [ ./hosts/parsley/configuration.nix ];
};
```

### Module Access

```nix
# Any module can access:
{ config, pkgs, lib, inputs, outputs, ... }:
{
  # inputs.nixpkgs, inputs.home-manager, etc.
  # outputs.overlays, outputs.darwinModules, etc.
}
```

## Package Management Strategy

### System Packages (Minimal)
```nix
# hosts/parsley/configuration.nix
environment.systemPackages = with pkgs; [
  git    # Essential for system
  curl   # Required for scripts
  wget   # Basic network tool
];
```

**Philosophy**: Only essential tools that need system-wide availability.

### User Packages (Comprehensive)  
```nix
# home/jrudnik/home.nix
home.packages = with pkgs; [
  # Development
  micro rustc cargo go python3
  
  # Utilities
  tree jq
  
  # Can be extensive
];
```

**Philosophy**: All development and personal tools via home-manager.

## Configuration Patterns

### Program Configuration

**Preferred pattern:**
```nix
programs.git = {
  enable = true;
  userName = "John Rudnik";
  userEmail = "john.rudnik@gmail.com";
  extraConfig = { ... };
};
```

**Why**: Uses home-manager's program modules for proper integration.

### System Settings (macOS)

**Pattern using modern pane-based system-settings module:**
```nix
# hosts/parsley/configuration.nix
darwin.system-settings = {
  enable = true;
  
  # Desktop & Dock pane (maps to System Settings > Desktop & Dock)
  desktopAndDock = {
    dock = {
      autohide = true;
      autohideDelay = 0.0;      # Instant response
      autohideTime = 0.15;      # Fast animation
      orientation = "bottom";
      showRecents = false;
      
      # Icon appearance
      magnification = true;
      tileSize = 45;            # Normal icon size
      largeSize = 70;           # Magnified size
      
      # Hot corners for productivity
      hotCorners = {
        topRight = 11;          # Launchpad
        bottomRight = 2;        # Mission Control
      };
    };
    
    missionControl = {
      separateSpaces = true;    # Better multi-monitor
      exposeAnimation = 0.15;   # Snappy animations
    };
  };
  
  # Keyboard pane (maps to System Settings > Keyboard)
  keyboard = {
    keyRepeat = 2;              # Fast key repeat
    initialKeyRepeat = 15;      # Short delay
    remapCapsLockToControl = true;
    enableFnKeys = true;
  };
  
  # Appearance pane (maps to System Settings > Appearance)
  appearance = {
    automaticSwitchAppearance = true;  # Auto light/dark mode
  };
  
  # Trackpad pane (maps to System Settings > Trackpad)
  trackpad = {
    naturalScrolling = false;   # Traditional scrolling
    tracking = 3;               # Cursor speed
  };
  
  # General pane (maps to System Settings > General + Finder)
  general = {
    textInput = {
      disableAutomaticCapitalization = true;
      disableAutomaticSpellingCorrection = true;
      disableAutomaticPeriodSubstitution = true;
    };
    
    finder = {
      showAllExtensions = true;
      showPathbar = true;
      showStatusBar = true;
      defaultViewStyle = "column";
    };
  };
};
```

**Why**: The `system-settings` module provides a pane-based interface that mirrors the macOS System Settings UI, making configuration intuitive and preventing NSGlobalDomain conflicts by using a single, unified configuration block. This is the **single source of truth** for all macOS system preferences.

### Service Management

**System services:**
```nix
# Via nix-darwin
launchd.daemons.my-service = { ... };
```

**User services:**  
```nix
# Via home-manager
launchd.agents.my-service = { ... };
```

## Extension Points

### Adding New Functionality

1. **Simple additions**: Edit configuration files directly
2. **Reusable functionality**: Create modules
3. **Package modifications**: Use overlays
4. **External tools**: Scripts directory

### Module Development

```nix
# 1. Create module
modules/darwin/my-feature/default.nix

# 2. Export in modules/darwin/default.nix
{
  my-feature = import ./my-feature;
}

# 3. Import in flake.nix (automatic via modules import)

# 4. Use in configuration
darwin.my-feature.enable = true;
```

## Build Process

### Build Flow

```
flake.nix
    ↓
Load inputs (nixpkgs, nix-darwin, home-manager)
    ↓
Evaluate darwinConfiguration
    ↓
Process all modules
    ↓
Generate system profile
    ↓
Activate configuration
```

### Build Commands

```bash
# Test build
darwin-rebuild build --flake .#parsley

# Apply changes
sudo darwin-rebuild switch --flake .#parsley

# Check flake
nix flake check
```

## Best Practices

### Configuration Organization

1. **Keep host configs minimal**: Most logic should be in modules
2. **Use modules for reusable features**: Don't duplicate configuration
3. **Separate concerns**: System vs user, configuration vs implementation
4. **Document decisions**: Add comments explaining non-obvious choices

### Module Design

1. **Single responsibility**: Each module handles one concern
2. **Rich options**: Provide sensible defaults with customization points
3. **Type safety**: Use appropriate Nix types for validation
4. **Documentation**: Every option should have a clear description

### File Organization

1. **Logical grouping**: Group related modules together
2. **Clear naming**: File names should reflect their purpose
3. **Consistent structure**: Follow the same patterns across modules
4. **Minimal nesting**: Keep directory structure flat when possible

## Common Patterns

### Conditional Configuration

```nix
config = mkIf cfg.enable {
  # Only apply when module is enabled
};
```

### Platform Detection

```nix
# In home-manager modules only
config = lib.mkIf pkgs.stdenv.isDarwin {
  # macOS-specific configuration
};
```

### Merging Lists

```nix
home.packages = with pkgs; [
  # Base packages
] ++ lib.optionals cfg.extraTools [
  # Optional packages
];
```

## Troubleshooting

### Configuration Won't Build

1. Check flake syntax: `nix flake check`
2. Build with trace: `darwin-rebuild build --flake .#parsley --show-trace`
3. Verify module imports are correct
4. Check for typos in option names

### Changes Not Applied

1. Ensure you used `sudo` for system changes
2. Restart affected services (Dock, Finder)
3. Check generation: `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system`
4. Verify configuration is active: `darwin-rebuild --version`

### Module Not Found

1. Verify module is exported in `modules/darwin/default.nix` or `modules/home/default.nix`
2. Check import path in flake.nix
3. Ensure module directory contains `default.nix`
4. Rebuild flake: `nix flake update`

## Next Steps

- **[Module Options Reference](module-options.md)** - Complete documentation of all module options
- **[Workflow Guide](../guides/workflow.md)** - Development and build processes
- **[Modular Architecture Guide](../guides/modular-architecture.md)** - Advanced module patterns
- **[Getting Started](../getting-started.md)** - Quick start guide for new users

---

This architecture provides a solid foundation for declarative macOS system management that's both powerful and maintainable.
