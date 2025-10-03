# Modular Architecture Guide

Understanding the advanced modular design of this Nix configuration.

## Overview

This configuration uses the **NixOS Module Pattern** to create a highly modular, reusable, and type-safe system. Instead of monolithic configuration files, functionality is broken down into focused, configurable modules.

### Key Benefits

✅ **Dramatic Simplification**: Host configs reduced from 100+ lines to 38 lines  
✅ **Type Safety**: Rich options with validation and documentation  
✅ **Reusability**: Zero code duplication across hosts and users  
✅ **Maintainability**: Clear separation of concerns  
✅ **Scalability**: Easy to add new hosts, users, and features  
✅ **Community Standard**: Follows advanced Nix patterns  

## The Module Pattern

### Structure

Every module follows this pattern:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.namespace.module-name;  # ← Shorthand reference
in {
  options.namespace.module-name = {
    # Define configurable options
    enable = mkEnableOption "Module description";
    
    someOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "What this option does";
    };
  };

  config = mkIf cfg.enable {
    # Implement the actual system configuration
    # Uses cfg.someOption to access user settings
  };
}
```

### The Components

1. **`cfg` Variable**: Creates a convenient shorthand for `config.namespace.module-name`
2. **`options`**: Declares what settings users can configure (the API)
3. **`config`**: Defines what actually happens when options are set (the implementation)
4. **`mkIf cfg.enable`**: Conditionally applies config only when enabled

## Module Architecture

### Darwin Modules (`modules/darwin/`)

System-level modules for macOS configuration:

#### `core` - Essential System Foundation
```nix
darwin.core = {
  enable = true;
  extraPackages = [ pkgs.htop ];  # Optional additional packages
};
```

**Provides:**
- Essential system packages (git, curl, wget)
- System architecture detection
- Shell configuration (zsh, bash completion)

#### `security` - Authentication & Users
```nix
darwin.security = {
  enable = true;
  primaryUser = "jrudnik";
  touchIdForSudo = true;
};
```

**Provides:**
- Touch ID authentication for sudo
- User account management
- Primary user designation for system defaults

#### `nix-settings` - Nix Daemon Configuration
```nix
darwin.nix-settings = {
  enable = true;
  trustedUsers = [ "jrudnik" ];
  garbageCollection.automatic = true;
  optimizeStore = true;
};
```

**Provides:**
- Nix daemon configuration
- Binary cache settings
- Automatic garbage collection
- Store optimization
- Trusted users management

#### `system-defaults` - macOS Preferences
```nix
darwin.system-defaults = {
  enable = true;
  dock.autohide = true;
  finder.showAllExtensions = true;
  globalDomain.disableAutomaticSpellingCorrection = true;
};
```

**Provides:**
- Dock configuration
- Finder settings
- Global domain preferences
- System UI behavior

### Home Manager Modules (`modules/home/`)

User-level modules for personal configuration:

#### `shell` - Terminal Environment
```nix
home.shell = {
  enable = true;
  configPath = "~/nix-config";
  hostName = "parsley";
  aliases = {
    deploy = "cd ~/projects && ./deploy.sh";
  };
  ohMyZsh.plugins = [ "git" "macos" "docker" ];
};
```

**Provides:**
- Zsh configuration with oh-my-zsh
- Intelligent aliases (including Nix shortcuts)
- Shell completion
- Direnv integration

#### `development` - Development Environment
```nix
home.development = {
  enable = true;
  languages = {
    rust = true;
    go = true;
    python = true;
    node = false;
  };
  editor = "micro";
  extraPackages = [ pkgs.docker pkgs.kubectl ];
};
```

**Provides:**
- Development languages and tools
- Text editor configuration
- Utility packages (tree, jq)
- Custom package additions

#### `git` - Version Control
```nix
home.git = {
  enable = true;
  userName = "John Doe";
  userEmail = "john@example.com";
  defaultBranch = "main";
  aliases = {
    st = "status";
    co = "checkout";
  };
};
```

**Provides:**
- Git user configuration
- Default branch settings
- Git aliases
- Additional git configuration

## Configuration Examples

### Complete System Configuration

```nix
# hosts/parsley/configuration.nix (38 lines)
{ inputs, outputs, ... }: {
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-defaults
  ];

  # Host identification
  networking.hostName = "parsley";

  # Module configuration
  darwin = {
    core.enable = true;
    
    security = {
      enable = true;
      primaryUser = "jrudnik";
    };
    
    nix-settings = {
      enable = true;
      trustedUsers = [ "jrudnik" ];
    };
    
    system-defaults.enable = true;
  };
}
```

### Complete Home Configuration

```nix
# home/jrudnik/home.nix (51 lines)
{ inputs, outputs, ... }: {
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
  ];

  # Home Manager basics
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };
  
  programs.home-manager.enable = true;

  # Module configuration
  home = {
    shell = {
      enable = true;
      aliases = {
        deploy = "cd ~/projects && ./deploy.sh";
        logs = "tail -f /var/log/system.log";
      };
    };
    
    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
      };
      editor = "micro";
    };
    
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
    };
  };
  
  xdg.enable = true;
}
```

## Extending the Architecture

### Adding a New Darwin Module

1. **Create the module**:
```bash
mkdir modules/darwin/homebrew
```

2. **Write the module** (`modules/darwin/homebrew/default.nix`):
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.homebrew;
in {
  options.darwin.homebrew = {
    enable = mkEnableOption "Homebrew package management";
    
    casks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew casks to install";
    };
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = cfg.casks;
    };
  };
}
```

3. **Export the module** (`modules/darwin/default.nix`):
```nix
{
  core = import ./core/default.nix;
  security = import ./security/default.nix;
  nix-settings = import ./nix-settings/default.nix;
  system-defaults = import ./system-defaults/default.nix;
  homebrew = import ./homebrew/default.nix;  # ← Add this
}
```

4. **Use the module** (`hosts/parsley/configuration.nix`):
```nix
{
  imports = [
    outputs.darwinModules.homebrew  # ← Add import
    # ... other imports
  ];

  darwin = {
    # ... other config
    homebrew = {
      enable = true;
      casks = [ "firefox" "discord" "docker" ];
    };
  };
}
```

### Adding a New Host

Creating a new host is incredibly simple with modules:

```nix
# hosts/workstation/configuration.nix
{ inputs, outputs, ... }: {
  imports = [
    # Same modules, different configuration!
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-defaults
  ];

  networking.hostName = "workstation";  # ← Only difference

  darwin = {
    core.enable = true;
    security = {
      enable = true;
      primaryUser = "different-user";  # ← Different user
    };
    nix-settings.enable = true;
    system-defaults = {
      enable = true;
      dock.orientation = "left";  # ← Custom preference
    };
  };
}
```

Then add to `flake.nix`:
```nix
darwinConfigurations = {
  parsley = /* ... */;
  workstation = nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs = self._specialArgs;
    modules = [ ./hosts/workstation/configuration.nix ];
  };
};
```

## Module Options Reference

### Type System

Modules use Nix's powerful type system:

```nix
options = {
  # Basic types
  enable = mkEnableOption "Feature description";
  name = mkOption { type = types.str; };
  count = mkOption { type = types.int; };
  flag = mkOption { type = types.bool; };
  
  # Collections
  packages = mkOption { type = types.listOf types.package; };
  settings = mkOption { type = types.attrsOf types.str; };
  
  # Constrained types
  level = mkOption { 
    type = types.enum [ "low" "medium" "high" ];
    default = "medium";
  };
  
  # Nested options
  database = {
    host = mkOption { type = types.str; };
    port = mkOption { type = types.port; default = 5432; };
  };
};
```

### Advanced Patterns

**Conditional configuration:**
```nix
config = mkIf cfg.enable {
  # Only applies when enabled
  environment.systemPackages = [ pkgs.git ]
    ++ optionals cfg.includeExtra cfg.extraPackages;
};
```

**Module composition:**
```nix
config = mkMerge [
  (mkIf cfg.basicFeatures { /* basic config */ })
  (mkIf cfg.advancedFeatures { /* advanced config */ })
];
```

**Assertions and warnings:**
```nix
config = {
  assertions = [{
    assertion = cfg.enable -> cfg.requiredOption != null;
    message = "requiredOption must be set when module is enabled";
  }];
  
  warnings = optional (cfg.deprecatedOption != null)
    "deprecatedOption is deprecated, use newOption instead";
};
```

## Best Practices

### Module Design

1. **Single Responsibility**: Each module handles one concern
2. **Rich Options**: Provide sensible defaults with customization
3. **Documentation**: Every option should have a clear description
4. **Type Safety**: Use appropriate types for validation
5. **Conditional Logic**: Use `mkIf` for optional features

### Configuration Organization

1. **Logical Grouping**: Group related options together
2. **Sane Defaults**: Modules should work with minimal configuration
3. **Clear Naming**: Use descriptive option names
4. **Consistent Patterns**: Follow the same structure across modules

### File Structure

```
modules/
├── darwin/
│   ├── category/          # Group by functionality
│   │   └── default.nix    # Implementation
│   └── default.nix        # Module exports
└── home/
    ├── program/
    │   └── default.nix
    └── default.nix
```

This modular architecture provides a powerful foundation that's both simple to use and easy to extend. It represents the state-of-the-art in Nix configuration management.