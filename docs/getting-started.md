# Getting Started with Nix Configuration

This guide will help you get up and running with this clean Nix configuration system using nix-darwin and Home Manager.

> **📚 Essential Reading:**
> - **[`workflow.md`](workflow.md)** - Complete workflow reference ⚡
> - **[`modular-architecture.md`](modular-architecture.md)** - Advanced modular design 🏗️
> - **[`architecture.md`](architecture.md)** - System architecture overview
> - **[`exceptions.md`](exceptions.md)** - Exception handling framework 🛡️
> - **[`quick-reference.md`](quick-reference.md)** - Quick commands and patterns

## Prerequisites

- macOS (Apple Silicon or Intel)
- Nix package manager installed with flakes enabled
- Basic familiarity with command line
- Git repository cloned locally

## Quick Start

### 1. Clone and Enter Directory
```bash
git clone https://github.com/jerudnik/nix-config.git ~/nix-config
cd ~/nix-config
```

### 2. Test Configuration Build
```bash
# Test system configuration build
./scripts/build.sh build

# Or manually:
darwin-rebuild build --flake .#parsley
```

### 3. Apply Configuration
```bash
# Apply system configuration (includes Home Manager)
./scripts/build.sh switch

# Or manually:
sudo darwin-rebuild switch --flake .#parsley
```

### 4. Verify Installation
```bash
# Check if packages are available
which micro git go python3 tree jq

# Check if aliases work
alias ll nrs nrb

# Check git config
git config --get user.name
git config --get user.email
```

## Configuration Structure

### Core Components

- **`flake.nix`** - Main flake definition with inputs and outputs
- **`hosts/parsley/configuration.nix`** - System configuration using nix-darwin
- **`home/jrudnik/home.nix`** - User configuration using Home Manager
- **`modules/`** - Reusable modules for darwin, home-manager, and nixos
- **`scripts/build.sh`** - Convenient build/switch/check script

### System vs Home Configuration

**System Configuration (`hosts/parsley/configuration.nix`)**
Controls **system-wide settings**:
- Security policies and authentication (Touch ID, firewall)
- System defaults (Dock, Finder, global preferences)
- System-wide packages (minimal set)
- Nix daemon configuration
- User account definitions

**Home Configuration (`home/jrudnik/home.nix`)**
Controls **user-specific settings**:
- Development environment and tools
- Shell configuration and aliases
- Personal applications and packages
- Git configuration
- Dotfiles and user preferences

## Common Tasks

### Modify System Settings

Edit `hosts/parsley/configuration.nix`:
```nix
system.defaults = {
  dock = {
    autohide = true;
    orientation = "bottom";
    show-recents = false;
    # Add more dock settings
  };
  
  finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
    ShowStatusBar = true;
  };
};
```

### Add Development Tools

Edit `home/jrudnik/home.nix`:
```nix
home.packages = with pkgs; [
  # Current tools
  git curl wget micro tree jq
  rustc cargo go python3
  
  # Add new tools
  nodejs yarn
  docker
  postman
];
```

### Update Shell Configuration

Edit the zsh configuration in `home/jrudnik/home.nix`:
```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  
  shellAliases = {
    # Current aliases
    ll = "ls -alF";
    nrs = "sudo darwin-rebuild switch --flake ~/nix-config#parsley";
    
    # Add custom aliases
    deploy = "cd ~/projects && ./deploy.sh";
    logs = "tail -f /var/log/system.log";
  };
  
  oh-my-zsh = {
    enable = true;
    plugins = [
      "git" "macos"
      # Add more plugins
      "docker" "node" "rust"
    ];
    theme = "robbyrussell";
  };
};
```

### Apply Changes

After making modifications:
```bash
# Test the build first
./scripts/build.sh build

# Apply the changes
./scripts/build.sh switch

# Or check for issues
./scripts/build.sh check
```

## Advanced Usage

### Create Custom Modules

1. **Create a Darwin module** (`modules/darwin/my-feature/default.nix`):
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my-feature;
in {
  options.my-feature = {
    enable = mkEnableOption "My custom feature";
    
    setting = mkOption {
      type = types.str;
      default = "default-value";
      description = "Custom setting description";
    };
  };

  config = mkIf cfg.enable {
    # Implementation here
  };
}
```

2. **Add to module exports** (`modules/darwin/default.nix`):
```nix
{
  my-feature = import ./my-feature;
}
```

3. **Import and use in host configuration**:
```nix
# In hosts/parsley/configuration.nix
imports = [
  # Add your module import
];

# Configure it
my-feature = {
  enable = true;
  setting = "custom-value";
};
```

### Manage Multiple Hosts

1. **Create new host directory**: `hosts/new-host/configuration.nix`
2. **Add to flake.nix**:
```nix
darwinConfigurations = {
  parsley = nix-darwin.lib.darwinSystem { ... };
  new-host = nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules = [
      ./hosts/new-host/configuration.nix
      # Add home-manager integration
    ];
  };
};
```
3. **Build with**: `darwin-rebuild switch --flake .#new-host`

### Manage Multiple Users

1. **Create new user directory**: `home/new-user/home.nix`
2. **Add to flake.nix**:
```nix
homeConfigurations = {
  "jrudnik@parsley" = home-manager.lib.homeManagerConfiguration { ... };
  "new-user@parsley" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs;
    modules = [ ./home/new-user/home.nix ];
  };
};
```

## Troubleshooting

### Configuration Won't Build
```bash
# Check flake syntax
nix flake check

# Build with detailed output
darwin-rebuild build --flake .#parsley --show-trace

# Check for specific errors
./scripts/build.sh build 2>&1 | less
```

### Packages Not Available After Switch
```bash
# Restart your shell session
exec zsh

# Or manually source the environment
source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
```

### Rollback Changes
```bash
# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nix-env --rollback --profile /nix/var/nix/profiles/system

# List home-manager generations
home-manager generations
```

### Permission Issues
```bash
# Make sure you're using sudo for darwin-rebuild switch
sudo darwin-rebuild switch --flake .#parsley

# Check file permissions in the nix-config directory
ls -la ~/nix-config/
```

## Next Steps

- **[Workflow Guide](workflow.md)** - Learn the development workflow
- **[Architecture Guide](architecture.md)** - Understand the system design
- **[Module Development](modules.md)** - Create custom modules
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions

## Migration from Other Systems

This configuration was designed to be:
- **Framework-independent**: No external abstractions like Nilla
- **Community-standard**: Following established Nix patterns
- **Maintainable**: Clear separation of concerns and minimal complexity
- **Extensible**: Easy to add modules and customize