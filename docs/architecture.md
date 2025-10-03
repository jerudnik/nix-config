# Architecture Guide

Understanding the design principles and structure of this Nix configuration.

## Design Philosophy

This configuration follows these key principles:

1. **No External Frameworks** - Direct use of nix-darwin and home-manager without abstractions
2. **Community Standards** - Follows established Nix community patterns and conventions  
3. **Clear Separation** - System vs user configuration, modules vs configuration
4. **Minimal Complexity** - Simple, understandable structure without over-engineering
5. **Maintainable** - Easy to debug, modify, and extend

## Directory Structure

```
~/nix-config/
├── flake.nix                 # Main flake: inputs, outputs, configurations
├── flake.lock                # Locked dependency versions
├── 
├── home/                     # Home Manager configurations
│   └── jrudnik/
│       └── home.nix          # User-specific configuration
├── 
├── hosts/                    # System configurations  
│   └── parsley/
│       └── configuration.nix # Darwin system configuration
├── 
├── modules/                  # Reusable modules
│   ├── darwin/               # nix-darwin modules
│   ├── home/                 # home-manager modules  
│   └── nixos/                # NixOS modules (future)
├── 
├── overlays/                 # Package overlays and modifications
│   └── default.nix           # Package customizations
├── 
├── scripts/                  # Helper scripts
│   └── build.sh              # Build/switch/check script
├── 
├── secrets/                  # Encrypted secrets (future)
└── docs/                     # Documentation
```

## Core Components

### Flake Architecture

```nix
{
  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";  
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {
    # System configurations
    darwinConfigurations.parsley = nix-darwin.lib.darwinSystem { ... };
    
    # User configurations  
    homeConfigurations."jrudnik@parsley" = home-manager.lib.homeManagerConfiguration { ... };
    
    # Reusable modules
    darwinModules = import ./modules/darwin;
    homeManagerModules = import ./modules/home;
  };
}
```

**Key aspects:**
- **Input following**: All inputs follow nixpkgs to maintain consistency
- **Special args**: Common arguments passed to all modules via `specialArgs`
- **Multiple outputs**: Separate system and home configurations for flexibility

### System Configuration Layer

**File**: `hosts/parsley/configuration.nix`

**Responsibilities:**
- System-wide settings and defaults
- User account management
- Security policies (Touch ID, firewall)
- Nix daemon configuration
- Essential system packages

**Integration with Home Manager:**
```nix
# Integrated approach (current)
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true; 
  extraSpecialArgs = specialArgs;
  users.jrudnik = import ./home/jrudnik/home.nix;
};
```

This integrates home-manager into the system build, ensuring consistency.

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
- **darwin/**: macOS system modules (nix-darwin)
- **home/**: User environment modules (home-manager)  
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

### System Defaults

**Pattern:**
```nix
system.defaults = {
  dock = {
    autohide = true;
    orientation = "bottom";
  };
  
  finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
  };
};
```

**Why**: Declarative macOS system configuration via nix-darwin.

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
imports = [ inputs.self.darwinModules.my-feature ];
my-feature.enable = true;
```

### Overlay System

```nix
# overlays/default.nix
{ inputs }: {
  my-overlay = final: prev: {
    my-package = prev.my-package.overrideAttrs (old: {
      # Modifications
    });
  };
}
```

## Integration Points

### nix-darwin Integration

- System activation runs as root
- Manages `/etc` files and system settings
- Handles user account creation
- Integrates with launchd for services

### Home Manager Integration

- Runs in user context
- Manages user dotfiles and configuration
- Handles user package installation
- Manages user services via launchd agents

### Build System Integration

```bash
# System + Home (integrated)
sudo darwin-rebuild switch --flake .#parsley

# Home only (standalone)  
home-manager switch --flake .#jrudnik@parsley
```

## Performance Considerations

### Binary Caches
```nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
};
```

### Build Optimization
```nix
nix = {
  settings.max-jobs = "auto";
  optimise.automatic = true;
  gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
};
```

### Flake Inputs Management
- Pin stable versions in `flake.lock`
- Update inputs selectively
- Use `follows` to reduce closure size

## Security Model

### Privilege Separation
- System changes require `sudo`
- Home changes run as user
- Secrets isolated in `secrets/` (future)

### Trust Model
```nix
nix.settings = {
  trusted-users = [ "root" "jrudnik" ];
  experimental-features = [ "nix-command" "flakes" ];
};
```

## Migration Path

This architecture supports gradual migration:

1. **Start simple**: Direct configuration in files
2. **Extract patterns**: Create modules for repeated functionality  
3. **Add complexity**: Overlays, secrets, multiple hosts/users
4. **Scale up**: Additional systems (NixOS, other macOS hosts)

The clean foundation makes each step straightforward without major refactoring.