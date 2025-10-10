# Modular Architecture Guide

Understanding the advanced modular design of this Nix configuration.

## Overview

This configuration uses the **NixOS Module Pattern** to create a highly modular, reusable, and type-safe system. Instead of monolithic configuration files, functionality is broken down into focused, configurable modules.

### Key Benefits

✅ **Significant Simplification**: Host configs reduced from 100+ lines to 78-81 lines
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

## Advanced Pattern: Aggregator/Implementor

### Purpose

Some modules benefit from separating **what** they do (the interface) from **how** they do it (the implementation). This is the **Aggregator/Implementor Pattern**.

**Benefits:**
- 🔄 **Swappable Implementations**: Change backend tools without affecting user configuration
- 🎯 **Clear Separation**: "What" vs "how" are in separate files
- 🛡️ **Isolation**: Tool-specific logic isolated from abstract interface
- 🧪 **Testability**: Easy to test different implementations
- 📈 **Maintainability**: Simpler to update or replace backend tools

### Structure

```
modules/darwin/theming/
├── default.nix    # Aggregator: Abstract interface ("what")
└── stylix.nix     # Implementor: Stylix-specific ("how")
```

### Example: Theming Module

#### Aggregator (`default.nix`)
Defines the abstract theming interface:

```nix
{ config, lib, ... }:

let
  cfg = config.darwin.theming;
in {
  imports = [
    ./stylix.nix  # Import implementor
  ];

  options.darwin.theming = {
    enable = mkEnableOption "System-wide theming";
    
    colorScheme = mkOption {
      type = types.enum [ "gruvbox-material-dark-medium" /* ... */ ];
      default = "gruvbox-material-dark-medium";
      description = ''Abstract color scheme option'';
    };
    
    polarity = mkOption {
      type = types.enum [ "light" "dark" "either" ];
      description = ''Theme polarity preference'';
    };
    
    # More abstract options...
  };
  
  # No config section - implementation delegated to backend
}
```

#### Implementor (`stylix.nix`)
Translates abstract options into Stylix-specific configuration:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.darwin.theming;
in {
  options.darwin.theming.implementation = {
    stylix.enable = mkEnableOption "Use Stylix" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.implementation.stylix.enable) {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
      polarity = cfg.polarity;
      # Stylix-specific configuration
    };
  };
}
```

### When to Use This Pattern

✅ **Use when:**
- Module wraps a specific tool (Stylix, AeroSpace, Bitwarden)
- Tool might be replaced in the future
- Tool has complex, tool-specific options
- Separation improves clarity

❌ **Don't use when:**
- Module is simple and direct
- No tool swapping is likely
- Adding complexity without benefit

### Current Implementations

This pattern is used in:
- `darwin/theming/` - Stylix backend for theming
- `home/window-manager/` - AeroSpace backend for window management
- `home/security/` - Bitwarden backend for password management (WARP LAW 4.3 compliant)

Planned for:
- `home/shell/` - Zsh/Oh-My-Zsh backend

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

#### `system-defaults` - macOS Preferences (Enhanced)
```nix
darwin.system-defaults = {
  enable = true;
  
  # Enhanced dock with 17+ options for productivity
  dock = {
    autohide = true;
    autohideDelay = 0.0;      # Instant response
    autohideTime = 0.15;      # Fast animation
    orientation = "left";     # Better screen usage
    magnification = true;     # Hover effects
    tileSize = 45;            # Icon size
    largeSize = 70;           # Magnified size
    showRecents = false;      # Clean appearance
    hotCorners = {
      topRight = 11;          # Launchpad
      bottomRight = 2;        # Mission Control
    };
  };
  
  finder.showAllExtensions = true;
  globalDomain.disableAutomaticSpellingCorrection = true;
};
```

**Provides:**
- **Advanced dock configuration** with animation timing, hot corners, magnification
- **Productivity-focused defaults** with snappy response and strategic shortcuts
- Finder settings and file management preferences
- Global domain text input and interface preferences
- **Automatic restart scripts** for immediate setting application

#### `keyboard` - Keyboard & Input Settings
```nix
darwin.keyboard = {
  enable = true;
  remapCapsLockToControl = true;  # Default
};
```

**Provides:**
- Caps Lock to Control key remapping
- Keyboard input method settings
- Modifier key configurations

#### `homebrew` - Package Management
```nix
darwin.homebrew = {
  enable = true;
  casks = [ "warp" "docker" ];
};
```

**Provides:**
- Homebrew cask management
- GUI application installation
- Declarative cask configuration


#### `theming` - System-Wide Theming (Aggregator/Implementor)
```nix
darwin.theming = {
  enable = true;
  colorScheme = "gruvbox-material-dark-medium";
  polarity = "either";  # Auto light/dark switching
  
  # Backend selection (optional, Stylix is default)
  implementation.stylix.enable = true;
};
```

**Provides:**
- Abstract theming interface (tool-agnostic)
- Stylix implementation backend (default)
- System-wide color theming
- Automatic light/dark mode switching
- Multiple color scheme options
- Application theme consistency

**Architecture:**
- Uses **Aggregator/Implementor Pattern**
- `default.nix` - Abstract interface ("what")
- `stylix.nix` - Stylix backend ("how")
- Easy to swap implementations in the future

#### `fonts` - Font Management
```nix
darwin.fonts = {
  enable = true;
  # iA Writer and Charter fonts enabled by default
};
```

**Provides:**
- iA Writer font family (Mono, Duo, Quattro)
- Charter serif font
- System font registration

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
  emacs = true;   # Optional: Excellent Stylix theming
  neovim = false; # Alternative to Emacs
  extraPackages = [ pkgs.docker pkgs.kubectl ];
};
```

**Provides:**
- Development languages and tools (Rust, Go, Python, Node.js)
- Text editor configuration (micro, nano, vim, emacs)
- Optional Emacs with automatic Stylix theming
- Optional Neovim with theming support
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

#### `cli-tools` - Modern CLI Utilities
```nix
home.cli-tools = {
  enable = true;
  systemMonitor = "btop";  # Options: "none", "htop", "btop"
  # eza, bat, ripgrep, fd, fzf, starship, alacritty enabled by default
};
```

**Provides:**
- Modern CLI replacements (eza, bat, ripgrep, fd)
- Fuzzy finder (fzf) with file integration
- Cross-shell prompt (starship) with git integration
- GPU-accelerated terminal (alacritty)
- System monitor (htop/btop with beautiful theming)
- Automatic shell integration

#### `window-manager` - Tiling Window Management (Aggregator/Implementor)
```nix
home.window-manager = {
  enable = true;
  
  # Abstract window management options
  startAtLogin = true;
  defaultLayout = "tiles";  # or "accordion"
  
  gaps = {
    inner = 8;  # Gap between windows
    outer = 8;  # Gap from screen edges
  };
  
  keybindings = {
    modifier = "alt";              # Primary modifier key
    terminal = "Warp";             # Alt+Enter launches terminal
    browser = "Zen Browser (Twilight)";
    passwordManager = "Bitwarden";
  };
  
  # Backend selection (optional, AeroSpace is default)
  implementation.aerospace.enable = true;
  implementation.aerospace.extraConfig = ''...'';  # TOML config
};
```

**Provides:**
- Abstract window management interface (tool-agnostic)
- AeroSpace implementation backend (default)
- Tiling window manager with vim-style keybindings
- Alt-based keyboard shortcuts (customizable)
- Auto-startup configuration
- Application launcher integration
- 10 workspace support with seamless switching
- Service mode for advanced operations

**Architecture:**
- Uses **Aggregator/Implementor Pattern**
- `default.nix` - Abstract interface ("what")
- `aerospace.nix` - AeroSpace backend ("how")
- Easy to swap implementations in the future

#### `security` - Password Management (Aggregator/Implementor + WARP LAW 4.3)
```nix
home.security = {
  enable = true;
  
  # Abstract password manager options
  autoStart = false;
  unlockMethod = "biometric";  # Touch ID unlock
  lockTimeout = 15;  # Auto-lock after 15 minutes
  windowBehavior = "minimize-to-tray";
  startBehavior = "normal";
  
  # Backend selection (optional, Bitwarden is default)
  implementation.bitwarden.enable = true;
  implementation.bitwarden.cli.enable = false;  # Optional CLI tool
};
```

**Provides:**
- Abstract password manager interface (tool-agnostic)
- Bitwarden implementation backend (default)
- Password management with Touch ID unlock
- Secure credential storage and autofill
- Optional CLI tool integration

**Architecture:**
- Uses **Aggregator/Implementor Pattern**
- `default.nix` - Abstract interface ("what")
- `bitwarden.nix` - Bitwarden backend ("how")
- **WARP LAW 4.3 COMPLIANCE**:
  - GUI app (Bitwarden.app): Installed via nix-darwin (system-level)
  - Configuration: Managed via home-manager (user-level)
  - CLI tool: Optional, installed via home-manager (user-level)
  - Clear separation between "install" and "configure"

#### `macos` - macOS-Specific Modules

Comprehensive macOS system integration with specialized modules for native functionality:

##### `home.macos.launchservices` - Default Applications
```nix
home.macos.launchservices = {
  enable = true;
  handlers = [
    { LSHandlerURLScheme = "http"; LSHandlerRoleAll = "zen.browser"; }
    { LSHandlerContentTag = "nix"; LSHandlerContentTagClass = "public.filename-extension"; LSHandlerRoleAll = "com.apple.Terminal"; }
  ];
};
```

**Provides:**
- Centralized default application management
- Conflict-free LSHandlers aggregation from multiple modules
- Automatic Launch Services database refresh
- Support for URL schemes, MIME types, and file extensions
- Integration with browser and other modules

##### `home.macos.keybindings` - Keyboard & Hotkeys
```nix
home.macos.keybindings = {
  enable = true;
  keyRepeat = 2;              # Fast key repeat
  initialKeyRepeat = 15;      # Short initial delay
  pressAndHoldEnabled = false; # Disable accent menu
  
  customSymbolicHotkeys = {
    "26" = { enabled = false; }; # Disable Mission Control
  };
};
```

**Provides:**
- Fast, responsive keyboard behavior optimized for development
- Automatic disabling of smart text features that interfere with coding
- System-wide hotkey management and customization
- Integration with Raycast (Spotlight hotkeys managed there)
- Immediate preference application via cache refresh

## Configuration Examples

### Complete System Configuration

```nix
# hosts/parsley/configuration.nix (81 lines)
{ inputs, outputs, ... }: {
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-defaults
    outputs.darwinModules.keyboard
    outputs.darwinModules.homebrew
    outputs.darwinModules.window-manager
    outputs.darwinModules.theming
    outputs.darwinModules.fonts
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
    
    system-defaults = {
      enable = true;
      # Enhanced dock with productivity hot corners
      dock = {
        autohide = true;
        autohideDelay = 0.0;
        autohideTime = 0.15;
        orientation = "left";
        magnification = true;
        showRecents = false;
        hotCorners = {
          topRight = 11;    # Launchpad
          bottomRight = 2;  # Mission Control
        };
        
        # Dock applications
        persistentApps = [
          "/Applications/Warp.app"
          "/Applications/Zen.app"
          "/System/Applications/Messages.app"
        ];
        
        # Dock folders
        persistentOthers = [
          "/Users/jrudnik/Downloads"
          "/Applications"
        ];
      };
    };
  };
}
```

### Complete Home Configuration

```nix
# home/jrudnik/home.nix (enhanced with macOS modules)
{ inputs, outputs, ... }: {
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    
    # macOS-specific modules
    outputs.homeManagerModules.macos.launchservices
    outputs.homeManagerModules.macos.keybindings
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
    
    # macOS UI enhancements
    macos.launchservices = {
      enable = true;
      defaultBrowser = "com.zen.browser";
      handlers = [
        { LSHandlerContentTag = "nix"; LSHandlerContentTagClass = "public.filename-extension"; LSHandlerRoleAll = "com.apple.Terminal"; }
      ];
    };
    
    macos.keybindings = {
      enable = true;
      keyRepeatRate = 2;
      initialKeyRepeatDelay = 15;
      disableAccentMenu = true;
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