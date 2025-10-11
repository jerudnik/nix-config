# Module Options Reference

**Last Updated:** October 10, 2025  
**Purpose:** Complete reference for all available configuration options across Darwin and Home Manager modules.

This document is the single source of truth for module options. All options listed here are verified against the source `.nix` files and represent the current state of the configuration.

---

## Table of Contents

- [Darwin Modules](#darwin-modules)
  - [core](#darwincore)
  - [security](#darwinsecurity)
  - [nix-settings](#darwinnix-settings)
  - [system-settings](#darwinsystem-settings)
  - [homebrew](#darwinhomebrew)
  - [theming](#darwintheming)
  - [fonts](#darwinfonts)
- [Home Modules](#home-modules)
  - [shell](#homeshell)
  - [development](#homedevelopment)
  - [git](#homegit)
  - [cli-tools](#homecli-tools)
  - [window-manager](#homewindow-manager)
  - [security](#homesecurity)
  - [ai](#homeai)
- [Configuration Examples](#configuration-examples)
- [Common Patterns](#common-patterns)

---

## Module Overview

**Darwin Modules (7):** System-level configuration for macOS  
**Home Modules (7):** User-level configuration via Home Manager

**Note:** This configuration has **7 top-level home modules**. Some modules like `starship` are sub-modules within parent modules (e.g., `starship` is part of `cli-tools`).

---

## Darwin Modules

### `darwin.core`

Essential system packages and base configuration.

```nix
darwin.core = {
  enable = true;                    # Enable core system configuration
  extraPackages = [                 # Additional system packages
    pkgs.htop
    pkgs.wget
  ];
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable core system configuration
- `extraPackages` (list of packages, default: `[]`) - Additional packages to install system-wide

**Provides:**
- Essential CLI tools (vim, curl, git)
- System utilities (tree, unzip, zip)
- Nix-specific tools (nix-tree, nix-output-monitor)
- Optional custom packages via `extraPackages`

---

### `darwin.security`

Security settings including Touch ID for sudo.

```nix
darwin.security = {
  enable = true;                    # Enable security configuration
  primaryUser = "jrudnik";          # Primary user for security settings
  touchIdForSudo = true;            # Enable Touch ID for sudo authentication
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable security configuration
- `primaryUser` (string, **required**) - Primary user account name
- `touchIdForSudo` (bool, default: `false`) - Enable Touch ID authentication for sudo

**Provides:**
- Touch ID authentication for sudo commands
- Secure primary user configuration
- macOS security best practices

---

### `darwin.nix-settings`

Nix daemon and package manager configuration.

```nix
darwin.nix-settings = {
  enable = true;                    # Enable Nix settings
  trustedUsers = [ "jrudnik" "admin" ];  # Additional trusted users
  garbageCollection = {
    automatic = true;               # Enable automatic garbage collection
    interval.Day = 7;               # Run every 7 days
    options = "--delete-older-than 30d";  # Delete generations older than 30 days
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Nix configuration
- `trustedUsers` (list of strings, default: `[]`) - Additional trusted Nix users (primary user added automatically)
- `garbageCollection.automatic` (bool, default: `true`) - Enable automatic garbage collection
- `garbageCollection.interval` (attrs, default: `{ Day = 7; }`) - How often to run GC
- `garbageCollection.options` (string, default: `"--delete-older-than 30d"`) - GC options

**Provides:**
- Optimized Nix daemon settings
- Binary cache configuration (cache.nixos.org, nix-community)
- Automatic garbage collection
- Experimental features (nix-command, flakes)
- Build optimization settings

---

### `darwin.system-settings`

Unified macOS System Settings configuration organized by preference panes.

**CRITICAL:** This module is the **single source of truth** for all `NSGlobalDomain` writes. It uses a unified configuration block to prevent preference domain conflicts and System Settings corruption.

```nix
darwin.system-settings = {
  enable = true;                    # Enable System Settings configuration
  
  # Desktop & Dock Pane
  desktopAndDock = {
    dock = {
      autohide = true;              # Auto-hide dock
      orientation = "bottom";       # Dock position: left, bottom, right
      tilesize = 48;                # Icon size (16-128)
      show-recents = false;         # Hide recent applications
      persistent-apps = [           # Pinned applications
        "/System/Applications/Calendar.app"
        "/Applications/Safari.app"
      ];
    };
    
    missionControl = {
      expose-group-apps = true;     # Group windows by application in Exposé
    };
    
    hotCorners = {
      tr = "Mission Control";       # Top-right corner action
      br = "Desktop";               # Bottom-right corner action
    };
  };
  
  # Keyboard Pane
  keyboard = {
    enableFullKeyboardAccess = true;          # Full keyboard access
    keyRepeatRate = 2;                        # Fast key repeat (1=fastest, 120=slowest)
    initialKeyRepeatDelay = 15;               # Short initial delay (1-120)
    disablePressAndHold = true;               # Disable accent menu, enable repeat
    remapCapsLockToControl = true;            # Remap Caps Lock to Control
    remapCapsLockToEscape = false;            # Alternative: remap to Escape
  };
  
  # Appearance Pane
  appearance = {
    enableAutoSwitch = true;                  # Auto light/dark mode
  };
  
  # Trackpad Pane
  trackpad = {
    enableNaturalScrolling = true;            # Natural scrolling direction
  };
  
  # General Pane
  general = {
    disableTextSubstitutions = true;          # Disable smart quotes, auto-correct
    expandSavePanel = true;                   # Always show expanded save dialogs
    expandPrintPanel = true;                  # Always show expanded print dialogs
    
    finder = {
      showAllExtensions = true;               # Show all file extensions
      showStatusBar = true;                   # Show status bar
      showPathBar = true;                     # Show path bar
      showFullPath = true;                    # Show full path in title
      defaultViewStyle = "Nlsv";              # List view
    };
  };
};
```

**Pane Organization:**
- **desktopAndDock**: Dock, Mission Control, Hot Corners
- **keyboard**: All keyboard settings (17+ options)
- **appearance**: Auto light/dark mode
- **trackpad**: Scroll direction
- **general**: Text input, Finder, panels

**Critical Architecture Note:**
This module uses a **unified configuration block** to write all settings in a single, coordinated operation. This prevents the NSGlobalDomain cache corruption that occurs when multiple modules write to the same preference domains independently.

**Key Features:**
- **Single source of truth** for NSGlobalDomain writes
- **Pane-based organization** matching macOS System Settings UI
- **Conflict prevention** via unified config block
- **Automatic service restarts** (Dock, Finder)
- **Preference validation** to detect corruption

---

### `darwin.homebrew`

Homebrew package manager for GUI applications.

```nix
darwin.homebrew = {
  enable = true;                    # Enable Homebrew
  casks = [                         # GUI applications to install
    "warp"                          # Warp terminal
    "claude"                        # Claude Desktop
    "visual-studio-code"            # VS Code
  ];
  taps = [];                        # Additional Homebrew taps
  brews = [];                       # CLI packages via Homebrew
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Homebrew integration
- `casks` (list of strings, default: `[]`) - GUI applications to install via `brew install --cask`
- `taps` (list of strings, default: `[]`) - Additional Homebrew taps to add
- `brews` (list of strings, default: `[]`) - CLI packages to install via Homebrew (prefer nixpkgs when possible)

**Provides:**
- Declarative Homebrew configuration
- GUI application management
- Automatic cleanup of unmanaged packages
- Integration with nix-darwin activation

**When to use Homebrew vs nixpkgs:**
- ✅ Use Homebrew for: GUI applications not in nixpkgs
- ❌ Avoid Homebrew for: CLI tools available in nixpkgs (use `core.extraPackages` instead)

---

### `darwin.theming`

System-wide theming with Stylix and automatic light/dark mode switching.

```nix
darwin.theming = {
  enable = true;                    # Enable theming
  stylix = {
    enable = true;                  # Use Stylix for theming
    colorScheme = "gruvbox-material-dark-medium";  # Base16 theme
    polarity = "either";            # Support both light/dark
    
    autoSwitch = {
      enable = true;                # Auto switch with macOS appearance
      lightScheme = "gruvbox-material-light-medium";
      darkScheme = "gruvbox-material-dark-medium";
    };
    
    fonts = {
      monospace = "iMWritingMonoNerdFont";
      sizes = {
        terminal = 14;
        applications = 12;
      };
    };
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable theming system
- `stylix.enable` (bool, default: `true`) - Use Stylix for theme management
- `stylix.colorScheme` (string, default: `"gruvbox-material-dark-medium"`) - Base16 color scheme name
- `stylix.polarity` (enum: `"light"` | `"dark"` | `"either"`, default: `"either"`) - Theme polarity
- `stylix.autoSwitch.enable` (bool, default: `false`) - Enable automatic theme switching
- `stylix.autoSwitch.lightScheme` (string) - Theme for light mode
- `stylix.autoSwitch.darkScheme` (string) - Theme for dark mode
- `stylix.fonts.monospace` (string, default: `"iMWritingMonoNerdFont"`) - Monospace font name
- `stylix.fonts.sizes.terminal` (int, default: `14`) - Terminal font size
- `stylix.fonts.sizes.applications` (int, default: `12`) - Application font size

**Provides:**
- Stylix theme management backend
- Automatic light/dark mode switching
- System-wide font configuration
- Theme switching utility (`nix-theme-switch`)
- Base16 color scheme support (200+ themes)

**Built-in Features:**
- **Gruvbox Material** as default (both light and dark variants)
- **Automatic switching** follows macOS System Settings
- **Manual control** via `nix-theme-switch` command
- **Consistent theming** across terminal, editor, and system

---

### `darwin.fonts`

System font installation and configuration.

```nix
darwin.fonts = {
  enable = true;                    # Enable font management
  extraFonts = [                    # Additional fonts to install
    pkgs.my-custom-font
  ];
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable font installation
- `extraFonts` (list of packages, default: `[]`) - Additional fonts beyond defaults

**Provides:**
- **Nerd Fonts collection** (programming fonts with icons)
- **iA Writer font families** (Mono, Duo, Quattro)
- **SF Pro** (macOS system font)
- **New York** (macOS serif font)
- Custom font support via `extraFonts`

**Default Nerd Fonts:**
- FiraCode, JetBrainsMono, Hack, SourceCodePro
- iMWritingMono, iMWritingDuo, iMWritingQuattro
- Meslo, RobotoMono, UbuntuMono, DejaVuSansMono

---

## Home Modules

### `home.shell`

Shell configuration with Zsh, oh-my-zsh, and intelligent aliases.

```nix
home.shell = {
  enable = true;                    # Enable shell configuration
  configPath = "~/nix-config";      # Path to nix config for shortcuts
  hostName = "parsley";             # Hostname for prompts
  
  aliases = {                       # Custom aliases
    k = "kubectl";
    tf = "terraform";
  };
  
  # Zsh backend configuration
  implementation.zsh = {
    enable = true;                  # Use Zsh (default)
    theme = "robbyrussell";         # oh-my-zsh theme
    plugins = [                     # oh-my-zsh plugins
      "git"
      "macos"
    ];
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable shell configuration
- `configPath` (string, default: `"~/nix-config"`) - Path to nix configuration for shortcuts
- `hostName` (string, default: `""`) - Hostname to display in prompts
- `aliases` (attrs, default: `{}`) - Custom shell aliases (highest priority)
- `implementation.zsh.enable` (bool, default: `true`) - Use Zsh as shell
- `implementation.zsh.theme` (string, default: `"robbyrussell"`) - oh-my-zsh theme
- `implementation.zsh.plugins` (list, default: `["git" "macos"]`) - oh-my-zsh plugins

**Provides:**
- **Modern CLI tool aliases**: `ls` → `eza`, `cat` → `bat`, `grep` → `rg`, `find` → `fd`
- **Nix operation shortcuts**: `nrs` (rebuild switch), `nrb` (rebuild build), `nfu` (flake update), `ngc` (garbage collect)
- **Development aliases**: `serve` (http server), `jsonpp` (JSON pretty print)
- **oh-my-zsh integration**: Themes, plugins, completions
- **Direnv integration**: Automatic environment activation
- **Environment configuration**: PATH, shell options

**Aggregator/Implementor Pattern:**
- Uses the aggregator/implementor pattern for shell flexibility
- Default: Zsh with oh-my-zsh
- Easy to swap: Fish, Nushell, Bash backends can be added

---

### `home.development`

Development environment with language support and editors.

```nix
home.development = {
  enable = true;                    # Enable development tools
  languages = {
    rust = true;                    # Rust toolchain
    go = true;                      # Go toolchain
    python = true;                  # Python environment
    node = false;                   # Node.js (optional)
  };
  editor = "micro";                 # Default editor
  neovim = false;                   # Neovim with theming
  extraPackages = [                 # Additional dev tools
    pkgs.docker
    pkgs.kubectl
  ];
  utilities = {
    enableBasicUtils = true;        # tree, jq, etc.
    lazygit = true;                 # Terminal UI for git
  };
  github = {
    enable = true;                  # GitHub CLI (gh)
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable development environment
- `languages.rust` (bool, default: `false`) - Install Rust toolchain
- `languages.go` (bool, default: `false`) - Install Go toolchain
- `languages.python` (bool, default: `false`) - Install Python environment
- `languages.node` (bool, default: `false`) - Install Node.js
- `editor` (enum: `"micro"` | `"nano"` | `"vim"` | `"emacs"`, default: `"micro"`) - Default text editor
- `neovim` (bool, default: `false`) - Install Neovim with Stylix theming
- `extraPackages` (list, default: `[]`) - Additional development packages
- `utilities.enableBasicUtils` (bool, default: `true`) - Install tree, jq, etc.
- `utilities.lazygit` (bool, default: `false`) - Install lazygit
- `github.enable` (bool, default: `false`) - Install GitHub CLI (gh)

**Provides:**
- **Language toolchains**: Rust (rustc, cargo), Go, Python, Node.js
- **Text editors**: micro (modern), nano, vim, optional Neovim/Emacs
- **Utilities**: tree, jq, yq, watch
- **Git helpers**: lazygit terminal UI
- **GitHub integration**: gh CLI with shell completion

---

### `home.git`

Git configuration and aliases.

```nix
home.git = {
  enable = true;                    # Enable git configuration
  userName = "John Doe";            # Git user name
  userEmail = "john@example.com";   # Git email
  defaultBranch = "main";           # Default branch name
  aliases = {                       # Git aliases
    st = "status";
    co = "checkout";
    br = "branch";
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable git configuration
- `userName` (string, **required**) - Git user.name
- `userEmail` (string, **required**) - Git user.email
- `defaultBranch` (string, default: `"main"`) - Default branch for new repositories
- `aliases` (attrs, default: `{}`) - Custom git aliases

**Provides:**
- User identity configuration
- Default branch settings
- Git aliases
- Sensible defaults (pull.rebase, init.defaultBranch)

---

### `home.cli-tools`

Modern CLI tools collection with advanced features.

**Note:** The `starship` prompt is configured as a **sub-module** within `cli-tools`, not a standalone top-level module.

```nix
home.cli-tools = {
  enable = true;                    # Enable CLI tools
  
  fileManager = {
    eza = true;                     # Modern ls (default: true)
    zoxide = true;                  # Smart cd (default: true)
    fzf = true;                     # Fuzzy finder (default: true)
  };
  
  textTools = {
    bat = true;                     # Syntax cat (default: true)
    ripgrep = true;                 # Fast grep (default: true)
    fd = true;                      # Fast find (default: true)
  };
  
  systemMonitor = "btop";           # Options: "none", "htop", "btop"
  
  shellEnhancements = {
    direnv = true;                  # Per-directory env (default: true)
    atuin = true;                   # Shell history (default: true)
    mcfly = false;                  # Alternative to atuin
    payRespects = true;             # Command correction (default: true)
  };
  
  gitTools = {
    delta = true;                   # Better git diff (default: true)
    gitui = false;                  # Terminal git UI
  };
};

# Starship configuration (sub-module of cli-tools)
home.starship = {
  enable = true;                    # Enable starship prompt
  theme = "gruvbox-rainbow";        # Prompt theme
  showLanguages = [                 # Languages to display
    "nodejs" "rust" "golang" "python" "nix_shell"
  ];
  showSystemInfo = true;            # Show OS/user/host
  showTime = true;                  # Show current time
  showBattery = true;               # Show battery status
  cmdDurationThreshold = 4000;      # Min ms to show cmd duration
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable CLI tools collection
- `fileManager.eza` (bool, default: `true`) - Modern ls replacement
- `fileManager.zoxide` (bool, default: `true`) - Smart directory navigation
- `fileManager.fzf` (bool, default: `true`) - Fuzzy finder
- `textTools.bat` (bool, default: `true`) - Syntax-highlighted cat
- `textTools.ripgrep` (bool, default: `true`) - Fast text search
- `textTools.fd` (bool, default: `true`) - Fast find alternative
- `systemMonitor` (enum, default: `"htop"`) - System monitor (`"none"` | `"htop"` | `"btop"`)
- `shellEnhancements.direnv` (bool, default: `true`) - Directory-specific environments
- `shellEnhancements.atuin` (bool, default: `true`) - Magical shell history
- `shellEnhancements.mcfly` (bool, default: `false`) - Alternative history search
- `shellEnhancements.payRespects` (bool, default: `true`) - Command correction
- `gitTools.delta` (bool, default: `true`) - Better git diff viewer
- `gitTools.gitui` (bool, default: `false`) - Terminal UI for git

**Starship Sub-Module Options:**
- `home.starship.enable` (bool, default: `false`) - Enable starship prompt
- `home.starship.theme` (enum, default: `"gruvbox-rainbow"`) - Prompt theme (`"gruvbox-rainbow"` | `"minimal"` | `"nerd-font-symbols"`)
- `home.starship.showLanguages` (list, default: `["nodejs" "rust" "golang" "python" "nix_shell"]`) - Languages to show
- `home.starship.showSystemInfo` (bool, default: `true`) - Show system info
- `home.starship.showTime` (bool, default: `true`) - Show current time
- `home.starship.showBattery` (bool, default: `true`) - Show battery status
- `home.starship.cmdDurationThreshold` (int, default: `4000`) - Min ms to display execution time

**Provides:**
- **File tools**: eza (ls+), zoxide (smart cd), fzf (fuzzy find)
- **Text tools**: bat (cat+), ripgrep (grep+), fd (find+)
- **Starship prompt**: Cross-shell, fast, informative
- **System monitors**: htop or btop with Stylix theming
- **Shell enhancements**: direnv, atuin/mcfly, pay-respects
- **Git enhancements**: delta diff viewer, optional gitui

---

### `home.window-manager`

Tiling window management for macOS with AeroSpace.

```nix
home.window-manager = {
  enable = true;                    # Enable window manager
  
  startAtLogin = true;              # Auto-start on login
  defaultLayout = "tiles";          # Default layout: "tiles" or "accordion"
  
  gaps = {
    inner = 8;                      # Gap between windows
    outer = 8;                      # Gap from screen edges
  };
  
  keybindings = {
    modifier = "alt";               # Primary modifier key
    terminal = "Warp";              # Terminal to launch (Alt+Enter)
    browser = "Zen Browser (Twilight)";
    passwordManager = "Bitwarden";
  };
  
  # Backend: AeroSpace (default implementation)
  implementation.aerospace = {
    enable = true;                  # Use AeroSpace (default: true)
    extraConfig = '''';             # Additional TOML config
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable window management
- `startAtLogin` (bool, default: `true`) - Auto-start on login
- `defaultLayout` (enum: `"tiles"` | `"accordion"`, default: `"tiles"`) - Default window layout
- `gaps.inner` (int, default: `8`) - Gap between windows in pixels
- `gaps.outer` (int, default: `8`) - Gap from screen edges in pixels
- `keybindings.modifier` (string, default: `"alt"`) - Primary modifier key
- `keybindings.terminal` (string, default: `"Warp"`) - Terminal application name
- `keybindings.browser` (string, optional) - Browser application name
- `keybindings.passwordManager` (string, optional) - Password manager application name
- `implementation.aerospace.enable` (bool, default: `true`) - Use AeroSpace backend
- `implementation.aerospace.extraConfig` (string, default: `""`) - Additional TOML configuration

**Provides:**
- **Tiling window management**: Automatic window organization
- **Keyboard-driven workflow**: Alt-based keybindings
- **Workspace navigation**: 10 workspaces (Alt+1-9, Alt+0)
- **Window manipulation**: Move, resize, focus with keyboard
- **Application launchers**: Quick launch for terminal, browser, password manager
- **Monitor support**: Multi-monitor workspace management

**Aggregator/Implementor Pattern:**
- Uses aggregator/implementor pattern for window manager flexibility
- Default: AeroSpace implementation
- Easy to swap: Yabai, Amethyst, etc. can be added as alternative backends

**Default Keybindings:**
- **Alt+Enter**: Launch terminal
- **Alt+1-9, Alt+0**: Switch workspaces
- **Alt+Shift+1-9, Alt+0**: Move window to workspace
- **Alt+H/J/K/L**: Focus window (vim-style)
- **Alt+Shift+H/J/K/L**: Move window
- **Alt+Tab**: Layout switch (tiles ↔ accordion)
- **Alt+F**: Toggle fullscreen

---

### `home.security`

Password management with Bitwarden integration.

```nix
home.security = {
  enable = true;                    # Enable security tools
  
  # Backend: Bitwarden (default implementation)
  implementation.bitwarden = {
    enable = true;                  # Use Bitwarden (default: true)
    touchId = true;                 # Touch ID unlock
    minimizeOnStart = true;         # Start minimized
    closeToTray = true;             # Close to tray, not quit
    lockTimeout = 15;               # Lock after 15 min
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable security tools
- `implementation.bitwarden.enable` (bool, default: `true`) - Use Bitwarden backend
- `implementation.bitwarden.touchId` (bool, default: `false`) - Enable Touch ID for unlock
- `implementation.bitwarden.minimizeOnStart` (bool, default: `false`) - Start minimized to tray
- `implementation.bitwarden.closeToTray` (bool, default: `false`) - Close button minimizes instead of quitting
- `implementation.bitwarden.lockTimeout` (int, default: `15`) - Lock timeout in minutes

**Provides:**
- **Bitwarden CLI**: Command-line password access
- **Touch ID unlock**: Quick, secure access
- **Tray behavior**: Keep running in background
- **Auto-lock**: Security timeout configuration
- **CLI integration**: Access passwords in terminal

**Aggregator/Implementor Pattern:**
- Uses aggregator/implementor pattern for password manager flexibility
- Default: Bitwarden implementation
- Easy to swap: 1Password, KeePassXC, etc. can be added as alternative backends

---

### `home.ai`

AI tools integration including Fabric patterns and Claude Desktop.

**Note:** MCP (Model Context Protocol) server configuration is **no longer a standalone module**. It's now managed via `mcp-servers-nix` integration, configured directly in `home.nix`.

```nix
home.ai = {
  enable = true;                    # Enable AI tools
  
  # Code analysis tools (code → prompt)
  codeAnalysis = {
    code2prompt = true;             # Full codebase to prompt
    filesToPrompt = true;           # Selected files to prompt
  };
  
  # LLM interfaces
  interfaces = {
    claudeDesktop = false;          # Managed via Homebrew
    copilotCli = true;              # GitHub Copilot CLI
    gooseCli = true;                # Goose AI assistant
  };
  
  # Fabric AI patterns
  patterns = {
    fabric = {
      enable = true;                # Enable Fabric patterns
      customPatterns = [];          # Additional patterns
    };
  };
  
  # Infrastructure
  secrets = {
    enable = true;                  # macOS Keychain secrets
    defaultKeys = [                 # API keys to manage
      "ANTHROPIC_API_KEY"
      "OPENAI_API_KEY"
      "GOOGLE_AI_API_KEY"
    ];
  };
  
  # Diagnostics
  diagnostics = {
    enable = true;                  # AI tools health checks
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable AI tools integration
- `codeAnalysis.code2prompt` (bool, default: `false`) - Full codebase to prompt converter
- `codeAnalysis.filesToPrompt` (bool, default: `false`) - Selected files to prompt converter
- `interfaces.claudeDesktop` (bool, default: `false`) - Claude Desktop (managed via Homebrew)
- `interfaces.copilotCli` (bool, default: `false`) - GitHub Copilot CLI
- `interfaces.gooseCli` (bool, default: `false`) - Goose AI assistant
- `patterns.fabric.enable` (bool, default: `false`) - Enable Fabric AI patterns
- `patterns.fabric.customPatterns` (list, default: `[]`) - Additional pattern directories
- `secrets.enable` (bool, default: `false`) - macOS Keychain secret management
- `secrets.defaultKeys` (list, default: `["ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GOOGLE_AI_API_KEY"]`) - API keys to manage
- `diagnostics.enable` (bool, default: `false`) - AI tools diagnostics (`ai-doctor` command)

**Provides:**
- **Code analysis**: Convert codebases to LLM-ready prompts
- **Fabric patterns**: 100+ AI patterns for various tasks
- **LLM interfaces**: Claude, Copilot, Goose CLI tools
- **Secret management**: Secure API key storage in macOS Keychain
- **Diagnostics**: `ai-doctor` command for troubleshooting
- **Management commands**: `ai-add-secret`, `ai-list-secrets`, `ai-remove-secret`

**Fabric Pattern Examples:**
- **Code tasks**: `summarize-code`, `review-code`, `explain-code`, `refactor-code`
- **Writing**: `improve-writing`, `create-summary`, `extract-key-points`
- **Analysis**: `analyze-claims`, `extract-wisdom`, `rate-content`

**MCP Integration (mcp-servers-nix):**
MCP servers are configured via `inputs.mcp-servers-nix` in your `home.nix`:
- **Filesystem**: Safe file operations (home directory only)
- **GitHub**: Repository access, PRs, issues, code search
- **Git**: Local repository operations
- **Time**: Date/time utilities
- **Web fetch**: HTTP requests and web scraping

See `docs/mcp.md` for complete MCP configuration documentation.

---

## Configuration Examples

### Minimal Configuration

```nix
# Minimal setup - just the essentials
darwin = {
  core.enable = true;
  security = {
    enable = true;
    primaryUser = "myuser";
  };
  nix-settings.enable = true;
};

home = {
  shell.enable = true;
  git = {
    enable = true;
    userName = "My Name";
    userEmail = "my@email.com";
  };
};
```

### Full-Featured Configuration

```nix
# Complete setup with customizations
darwin = {
  core = {
    enable = true;
    extraPackages = with pkgs; [ htop neofetch ];
  };
  
  security = {
    enable = true;
    primaryUser = "developer";
    touchIdForSudo = true;
  };
  
  nix-settings = {
    enable = true;
    trustedUsers = [ "developer" "admin" ];
    garbageCollection.options = "--delete-older-than 14d";
  };
  
  system-settings = {
    enable = true;
    desktopAndDock = {
      dock = {
        autohide = true;
        orientation = "left";
        tilesize = 56;
      };
      missionControl.expose-group-apps = true;
      hotCorners = {
        tr = "Mission Control";
        br = "Desktop";
      };
    };
    keyboard = {
      enableFullKeyboardAccess = true;
      keyRepeatRate = 2;
      initialKeyRepeatDelay = 15;
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
    casks = [ "warp" "claude" "visual-studio-code" ];
  };
};

home = {
  shell = {
    enable = true;
    aliases = {
      k = "kubectl";
      tf = "terraform";
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
```

---

## Common Patterns

### Aggregator/Implementor Pattern

Some modules use an **aggregator/implementor pattern** for flexibility:
- **Aggregator** defines abstract interface (e.g., `home.window-manager`)
- **Implementor** provides concrete backend (e.g., `aerospace.nix`)
- Allows swapping implementations without changing configuration
- Current examples: `window-manager`, `security`, `theming`, `starship`, `shell`

### Module Structure

- **7 Darwin modules**: System-level macOS configuration
- **7 Home modules**: User-level configuration via Home Manager
- **Sub-modules**: Some modules have sub-modules (e.g., `starship` within `cli-tools`)

### Naming Conventions

- **darwin.*** → System-level configuration (requires sudo to apply)
- **home.*** → User-level configuration (no sudo required)
- **Pane-based**: `system-settings` organized by macOS System Settings UI panes

### Configuration Principles

- **Single source of truth**: `system-settings` is the only module writing to NSGlobalDomain
- **Never create separate modules** for nixpkgs programs (use built-in `programs.*` options)
- **Prefer nixpkgs over Homebrew** for CLI tools
- **Use Homebrew only** for GUI applications not in nixpkgs
- **Avoid NSGlobalDomain conflicts**: Let `system-settings` handle all system preference writes

### Finding More Information

- **Source files:** `modules/darwin/` and `modules/home/`
- **Documentation:** `docs/architecture.md`, `docs/modular-architecture.md`
- **Examples:** `hosts/parsley/configuration.nix`, `home/jrudnik/home.nix`
- **WARP rules:** `WARP.md` for architectural principles

---

**End of Module Options Reference**
