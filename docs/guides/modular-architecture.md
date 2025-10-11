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

---

## Module Structure

### Module Counts

**Darwin Modules (7):** System-level macOS configuration
- `core`, `security`, `nix-settings`, `system-settings`, `homebrew`, `theming`, `fonts`

**Home Modules (7):** User-level configuration via Home Manager
- `shell`, `development`, `git`, `cli-tools`, `window-manager`, `security`, `ai`

**Note on Sub-Modules:**
- **`starship`** is a sub-module within `cli-tools` (not a top-level module)
- **`mcp`** module was removed and replaced with `mcp-servers-nix` integration

---

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

---

## Advanced Pattern: Aggregator/Implementor

### Purpose

Some modules benefit from separating **what** they do (the interface) from **how** they do it (the implementation). This is the **Aggregator/Implementor Pattern**.

### When to Use This Pattern

Use this pattern when a module:
1. **Could have multiple backends** (different tools doing the same job)
2. **Has tool-specific options** that don't belong in the abstract interface
3. **Benefits from future flexibility** (easy to swap implementations)

### Example: `darwin.theming`

**Problem**: Theming can be done by Stylix, Catppuccin, base16, etc. We want to support multiple theming tools without changing the user-facing configuration.

**Solution**: Split into aggregator + implementor.

#### Aggregator (`default.nix`)

Defines **what** theming does, tool-agnostically:

```nix
{ config, lib, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  imports = [
    ./stylix.nix  # Import implementor
  ];

  options.darwin.theming = {
    enable = mkEnableOption "System-wide theming";
    
    # Abstract, tool-agnostic options
    colorScheme = mkOption {
      type = types.str;
      default = "gruvbox-material-dark-medium";
      description = "Base16 color scheme name";
    };
    
    autoSwitch = {
      enable = mkEnableOption "Automatic light/dark theme switching";
      lightScheme = mkOption { type = types.str; };
      darkScheme = mkOption { type = types.str; };
    };
    
    polarity = mkOption {
      type = types.enum [ "light" "dark" "either" ];
      default = "either";
      description = "Theme polarity preference";
    };
  };

  # No config section here!
  # Implementation is delegated to backend modules (stylix.nix)
}
```

#### Implementor (`stylix.nix`)

Defines **how** Stylix implements theming:

```nix
{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.darwin.theming;
in {
  options.darwin.theming.stylix = {
    enable = mkEnableOption "Use Stylix for theming";
    # Stylix-specific options can go here
  };

  config = mkIf (cfg.enable && cfg.stylix.enable) {
    # Map abstract theming options to Stylix configuration
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
      polarity = cfg.polarity;
      
      # Auto-switching logic
      autoEnable = cfg.autoSwitch.enable;
      # ... more Stylix-specific config
    };
    
    # Theme switching utility
    environment.systemPackages = [ pkgs.nix-theme-switch ];
  };
}
```

#### User Configuration

User's configuration stays the same regardless of backend:

```nix
darwin.theming = {
  enable = true;
  colorScheme = "gruvbox-material-dark-medium";
  autoSwitch.enable = true;
  
  # Backend selection (optional, Stylix is default)
  stylix.enable = true;
};
```

### Benefits of This Pattern

1. **Easy to swap backends**: Add `catppuccin.nix`, user changes one line
2. **Clean separation**: Abstract API vs tool-specific implementation
3. **Future-proof**: New theming tools can be added without breaking existing config
4. **Reusable pattern**: Same approach works for shells, window managers, password managers

---

## Module Examples

### Darwin Modules

#### `core` - Essential System Packages

```nix
darwin.core = {
  enable = true;
  extraPackages = with pkgs; [ htop neofetch ];
};
```

**Provides:**
- Essential CLI tools (vim, curl, git)
- System utilities (tree, unzip, zip)
- Nix-specific tools
- Custom package support

---

#### `system-settings` - Unified System Settings

**CRITICAL ARCHITECTURE NOTE:**

This module is the **single source of truth** for all `NSGlobalDomain` writes. It uses a **unified configuration block** to prevent the NSGlobalDomain cache corruption that occurs when multiple modules write to the same preference domains.

```nix
darwin.system-settings = {
  enable = true;
  
  # Desktop & Dock Pane
  desktopAndDock = {
    dock = {
      autohide = true;
      orientation = "left";
      tilesize = 56;
      persistent-apps = [
        "/Applications/Warp.app"
        "/Applications/Zen.app"
      ];
    };
    missionControl.expose-group-apps = true;
    hotCorners = {
      tr = "Mission Control";
      br = "Desktop";
    };
  };
  
  # Keyboard Pane
  keyboard = {
    enableFullKeyboardAccess = true;
    keyRepeatRate = 2;
    initialKeyRepeatDelay = 15;
    disablePressAndHold = true;
    remapCapsLockToControl = true;
  };
  
  # Appearance Pane
  appearance = {
    enableAutoSwitch = true;  # Auto light/dark mode
  };
  
  # Trackpad Pane
  trackpad = {
    enableNaturalScrolling = true;
  };
  
  # General Pane
  general = {
    disableTextSubstitutions = true;
    expandSavePanel = true;
    
    finder = {
      showAllExtensions = true;
      showStatusBar = true;
      showPathBar = true;
    };
  };
};
```

**Provides:**
- **Pane-based organization** matching macOS System Settings UI
- **Single source of truth** for NSGlobalDomain writes
- **Unified config block** preventing preference domain conflicts
- **Automatic service restarts** (Dock, Finder)
- **Preference validation** to detect corruption

**Architecture:**
This is the most important example of **conflict prevention** in the configuration. Before this unified approach, multiple modules writing to NSGlobalDomain caused System Settings to display blank panes. Now, all settings flow through a single, coordinated configuration block.

---

#### `theming` - System-Wide Appearance (Aggregator/Implementor)

```nix
darwin.theming = {
  enable = true;
  stylix = {
    enable = true;
    colorScheme = "gruvbox-material-dark-medium";
    polarity = "either";
    
    autoSwitch = {
      enable = true;
      lightScheme = "gruvbox-material-light-medium";
      darkScheme = "gruvbox-material-dark-medium";
    };
  };
};
```

**Provides:**
- Stylix theming backend
- Automatic light/dark mode switching
- Base16 color scheme support (200+ themes)
- System-wide font configuration
- Theme switching utility

**Aggregator/Implementor Pattern:**
- **Aggregator**: Defines tool-agnostic theming API
- **Implementor**: Stylix backend (could add Catppuccin, base16, etc.)

---

### Home Modules

#### `shell` - Shell Configuration (Aggregator/Implementor)

```nix
home.shell = {
  enable = true;
  configPath = "~/nix-config";
  hostName = "parsley";
  
  aliases = {
    k = "kubectl";
    deploy = "cd ~/projects && ./deploy.sh";
  };
  
  # Zsh backend (default implementation)
  implementation.zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [ "git" "macos" ];
  };
};
```

**Provides:**
- **Modern CLI tool aliases**: `ls` → `eza`, `cat` → `bat`, `grep` → `rg`
- **Nix operation shortcuts**: `nrs`, `nrb`, `nfu`, `ngc`
- **oh-my-zsh integration**: Themes, plugins, completions
- **Direnv integration**: Automatic environment activation
- **Environment configuration**: PATH, shell options

**Aggregator/Implementor Pattern:**
- **Aggregator**: Tool-agnostic shell interface
- **Implementor**: Zsh backend (could add Fish, Nushell, Bash)

---

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
  neovim = false;
  extraPackages = [ pkgs.docker pkgs.kubectl ];
  utilities = {
    enableBasicUtils = true;
    lazygit = true;
  };
  github.enable = true;
};
```

**Provides:**
- **Language toolchains**: Rust, Go, Python, Node.js
- **Text editors**: micro, nano, vim, optional Neovim/Emacs
- **Utilities**: tree, jq, yq, watch
- **Git helpers**: lazygit terminal UI
- **GitHub integration**: gh CLI with shell completion

---

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
    br = "branch";
  };
};
```

**Provides:**
- User identity configuration
- Default branch settings
- Git aliases
- Sensible defaults

---

#### `cli-tools` - Modern CLI Tools Collection

**IMPORTANT:** The `starship` prompt is configured as a **sub-module** within `cli-tools`, not a standalone top-level module.

```nix
home.cli-tools = {
  enable = true;
  
  fileManager = {
    eza = true;
    zoxide = true;
    fzf = true;
  };
  
  textTools = {
    bat = true;
    ripgrep = true;
    fd = true;
  };
  
  systemMonitor = "btop";
  
  shellEnhancements = {
    direnv = true;
    atuin = true;
    payRespects = true;
  };
  
  gitTools = {
    delta = true;
    gitui = false;
  };
};

# Starship configuration (sub-module of cli-tools)
home.starship = {
  enable = true;
  theme = "gruvbox-rainbow";
  showLanguages = [ "nodejs" "rust" "golang" "python" "nix_shell" ];
  showSystemInfo = true;
  showTime = true;
  showBattery = true;
  cmdDurationThreshold = 4000;
};
```

**Provides:**
- **File tools**: eza (ls+), zoxide (smart cd), fzf (fuzzy find)
- **Text tools**: bat (cat+), ripgrep (grep+), fd (find+)
- **Starship prompt**: Cross-shell, fast, informative (via sub-module)
- **System monitors**: htop or btop with Stylix theming
- **Shell enhancements**: direnv, atuin, pay-respects
- **Git enhancements**: delta diff viewer

**Sub-Module Architecture:**
- `starship` is configured via `home.starship.*` options
- It's part of the `cli-tools` module, not a separate top-level module
- This provides better organization while keeping the configuration intuitive

---

#### `window-manager` - Tiling Window Management (Aggregator/Implementor)

```nix
home.window-manager = {
  enable = true;
  
  # Abstract window management options
  startAtLogin = true;
  defaultLayout = "tiles";
  
  gaps = {
    inner = 8;
    outer = 8;
  };
  
  keybindings = {
    modifier = "alt";
    terminal = "Warp";
    browser = "Zen Browser (Twilight)";
    passwordManager = "Bitwarden";
  };
  
  # Backend: AeroSpace (default implementation)
  implementation.aerospace = {
    enable = true;
    extraConfig = '''';
  };
};
```

**Provides:**
- **Tiling window management**: Automatic window organization
- **Keyboard-driven workflow**: Alt-based keybindings
- **Workspace navigation**: 10 workspaces
- **Window manipulation**: Move, resize, focus with keyboard
- **Application launchers**: Quick launch for common apps

**Aggregator/Implementor Pattern:**
- **Aggregator**: Tool-agnostic window manager interface
- **Implementor**: AeroSpace backend (could add Yabai, Amethyst, etc.)

**Default Keybindings:**
- **Alt+Enter**: Launch terminal
- **Alt+1-9, Alt+0**: Switch workspaces
- **Alt+H/J/K/L**: Focus window (vim-style)
- **Alt+Tab**: Layout switch

---

#### `security` - Password Management (Aggregator/Implementor)

```nix
home.security = {
  enable = true;
  
  # Backend: Bitwarden (default implementation)
  implementation.bitwarden = {
    enable = true;
    touchId = true;
    minimizeOnStart = true;
    closeToTray = true;
    lockTimeout = 15;
  };
};
```

**Provides:**
- **Bitwarden CLI**: Command-line password access
- **Touch ID unlock**: Quick, secure access
- **Tray behavior**: Keep running in background
- **Auto-lock**: Security timeout configuration

**Aggregator/Implementor Pattern:**
- **Aggregator**: Tool-agnostic password manager interface
- **Implementor**: Bitwarden backend (could add 1Password, KeePassXC, etc.)

---

#### `ai` - AI Tools Integration

**IMPORTANT:** MCP (Model Context Protocol) is **no longer a standalone module**. It's now managed via `mcp-servers-nix` integration in `home.nix`.

```nix
home.ai = {
  enable = true;
  
  # Code analysis tools
  codeAnalysis = {
    code2prompt = true;
    filesToPrompt = true;
  };
  
  # LLM interfaces
  interfaces = {
    claudeDesktop = false;  # Managed via Homebrew
    copilotCli = true;
    gooseCli = true;
  };
  
  # Fabric AI patterns
  patterns = {
    fabric = {
      enable = true;
      customPatterns = [];
    };
  };
  
  # Infrastructure
  secrets = {
    enable = true;
    defaultKeys = [
      "ANTHROPIC_API_KEY"
      "OPENAI_API_KEY"
      "GOOGLE_AI_API_KEY"
    ];
  };
  
  # Diagnostics
  diagnostics = {
    enable = true;
  };
};
```

**Provides:**
- **Code analysis**: Convert codebases to LLM-ready prompts
- **Fabric patterns**: 100+ AI patterns for various tasks
- **LLM interfaces**: Claude, Copilot, Goose CLI tools
- **Secret management**: Secure API key storage in macOS Keychain
- **Diagnostics**: `ai-doctor` command for troubleshooting

**Module Organization (Functional Structure):**
```
modules/home/ai/
├── code-analysis/      # Code → prompt converters
│   ├── code2prompt.nix
│   └── files-to-prompt.nix
├── interfaces/         # LLM interaction tools
│   ├── claude-desktop.nix
│   ├── copilot-cli.nix
│   └── goose-cli.nix
├── infrastructure/     # Supporting systems
│   └── secrets.nix
├── patterns/           # AI patterns
│   └── fabric/
└── utilities/          # Management tools
    └── diagnostics.nix
```

**MCP Integration:**
MCP servers are configured via `inputs.mcp-servers-nix` directly in your `home.nix`:
- **Filesystem**: Safe file operations
- **GitHub**: Repository access
- **Git**: Local repository operations
- **Time**: Date/time utilities
- **Web fetch**: HTTP requests

See `docs/mcp.md` for complete MCP configuration documentation.

---

## Configuration Examples

### Complete System Configuration

```nix
# hosts/parsley/configuration.nix (81 lines)
{ inputs, outputs, ... }: {
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-settings
    outputs.darwinModules.homebrew
    outputs.darwinModules.theming
    outputs.darwinModules.fonts
  ];

  networking.hostName = "parsley";

  darwin = {
    core.enable = true;
    
    security = {
      enable = true;
      primaryUser = "jrudnik";
      touchIdForSudo = true;
    };
    
    nix-settings.enable = true;
    
    system-settings = {
      enable = true;
      desktopAndDock = {
        dock = {
          autohide = true;
          orientation = "left";
          tilesize = 56;
        };
        missionControl.expose-group-apps = true;
      };
      keyboard = {
        enableFullKeyboardAccess = true;
        keyRepeatRate = 2;
        remapCapsLockToControl = true;
      };
      appearance.enableAutoSwitch = true;
    };
    
    theming = {
      enable = true;
      stylix = {
        enable = true;
        colorScheme = "gruvbox-material-dark-medium";
        autoSwitch.enable = true;
      };
    };
    
    homebrew = {
      enable = true;
      casks = [ "warp" "claude" ];
    };
  };
  
  system.stateVersion = 5;
}
```

### Complete Home Configuration

```nix
# home/jrudnik/home.nix (78 lines)
{ inputs, outputs, ... }: {
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    outputs.homeManagerModules.window-manager
    outputs.homeManagerModules.security
    outputs.homeManagerModules.ai
  ];

  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };
  
  programs.home-manager.enable = true;

  home = {
    shell = {
      enable = true;
      aliases = {
        k = "kubectl";
      };
    };
    
    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
      };
      neovim = true;
    };
    
    cli-tools.enable = true;
    
    starship = {
      enable = true;
      theme = "gruvbox-rainbow";
    };
    
    window-manager = {
      enable = true;
      keybindings = {
        terminal = "Warp";
        browser = "Zen Browser (Twilight)";
      };
    };
    
    security = {
      enable = true;
      implementation.bitwarden.touchId = true;
    };
    
    ai = {
      enable = true;
      interfaces.copilotCli = true;
      patterns.fabric.enable = true;
      secrets.enable = true;
    };
  };
  
  xdg.enable = true;
}
```

---

## Extending the Architecture

### Adding a New Darwin Module

1. **Create the module**:
```bash
mkdir modules/darwin/my-feature
```

2. **Write the module** (`modules/darwin/my-feature/default.nix`):
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.my-feature;
in {
  options.darwin.my-feature = {
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

3. **Export the module** (`modules/darwin/default.nix`):
```nix
{
  core = import ./core/default.nix;
  security = import ./security/default.nix;
  my-feature = import ./my-feature/default.nix;  # ← Add this
  # ... other modules
}
```

4. **Use the module** (`hosts/parsley/configuration.nix`):
```nix
{
  imports = [
    outputs.darwinModules.my-feature  # ← Add import
    # ... other imports
  ];

  darwin.my-feature = {
    enable = true;
    setting = "custom-value";
  };
}
```

---

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
    outputs.darwinModules.system-settings
  ];

  networking.hostName = "workstation";

  darwin = {
    core.enable = true;
    security = {
      enable = true;
      primaryUser = "different-user";
    };
    # Different configuration, same modules!
    system-settings = {
      enable = true;
      desktopAndDock.dock.orientation = "bottom";  # Different from "parsley"
    };
  };
  
  system.stateVersion = 5;
}
```

**Key Point:** No code duplication! Just different configuration values.

---

### Adding a New User

```nix
# home/newuser/home.nix
{ inputs, outputs, ... }: {
  imports = [
    # Same modules, different user!
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
  ];

  home = {
    username = "newuser";
    homeDirectory = "/Users/newuser";
    stateVersion = "25.05";
  };

  home = {
    shell.enable = true;
    
    git = {
      enable = true;
      userName = "New User";
      userEmail = "newuser@example.com";
    };
    
    development = {
      enable = true;
      languages.python = true;  # Different from other users
    };
  };
}
```

**Key Point:** Same modules, different personal settings!

---

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

### Aggregator/Implementor Usage

**Use this pattern when:**
- Multiple tools could provide the same functionality
- You want to support tool swapping in the future
- Tool-specific options don't belong in the abstract interface

**Don't use this pattern when:**
- Only one tool will ever be used
- The module is already simple enough
- Over-engineering would reduce clarity

---

## File Structure

```
modules/
├── darwin/
│   ├── category/          # Group by functionality
│   │   └── default.nix    # Implementation
│   └── default.nix        # Module exports
└── home/
    ├── program/
    │   ├── default.nix           # Aggregator (if using pattern)
    │   └── implementor.nix       # Implementor (if using pattern)
    └── default.nix
```

---

## Summary

This modular architecture provides:

✅ **Powerful abstractions** through the NixOS module pattern  
✅ **Flexibility** via aggregator/implementor for multi-backend support  
✅ **Type safety** with rich option definitions  
✅ **Reusability** across hosts and users with zero duplication  
✅ **Maintainability** through clear separation of concerns  
✅ **Scalability** for easy addition of hosts, users, and features  

It represents the state-of-the-art in Nix configuration management, combining community best practices with innovative patterns for maximum flexibility and minimal complexity.
