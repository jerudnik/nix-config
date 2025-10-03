# Module Options Reference

Complete reference for all available options in each module.

## Darwin Modules

### `darwin.core`

Essential system packages and shell configuration.

```nix
darwin.core = {
  enable = true;                    # Enable the core module
  extraPackages = [];               # Additional system packages
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable essential system packages and shell
- `extraPackages` (list of packages, default: `[]`) - Additional system packages to install

**Provides:**
- Essential packages: `git`, `curl`, `wget`
- System architecture detection (`aarch64-darwin`)
- System-wide shell configuration (zsh, bash completion)

**Example:**
```nix
darwin.core = {
  enable = true;
  extraPackages = with pkgs; [ htop neofetch ];
};
```

---

### `darwin.security`

Touch ID authentication and user management.

```nix
darwin.security = {
  enable = true;                    # Enable security module
  touchIdForSudo = true;            # Enable Touch ID for sudo
  primaryUser = "username";         # Primary user for system defaults
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable security features
- `touchIdForSudo` (bool, default: `true`) - Enable Touch ID for sudo authentication
- `primaryUser` (string, **required**) - Primary user name for system-wide defaults

**Provides:**
- Touch ID authentication for sudo commands
- User account creation and management
- Primary user designation for system defaults

**Example:**
```nix
darwin.security = {
  enable = true;
  primaryUser = "jrudnik";
  touchIdForSudo = true;
};
```

---

### `darwin.nix-settings`

Nix daemon configuration and optimization.

```nix
darwin.nix-settings = {
  enable = true;                    # Enable nix settings
  trustedUsers = [ "username" ];    # Additional trusted users
  garbageCollection = {
    automatic = true;               # Enable automatic GC
    interval = { Weekday = 7; Hour = 3; Minute = 15; };
    options = "--delete-older-than 30d";
  };
  optimizeStore = true;             # Enable store optimization
  extraSubstituters = [];          # Additional binary caches
  extraPublicKeys = [];            # Additional public keys
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Nix daemon configuration
- `trustedUsers` (list of strings, default: `[ "root" ]`) - Users trusted for Nix operations
- `garbageCollection.automatic` (bool, default: `true`) - Enable automatic garbage collection
- `garbageCollection.interval` (attrs, default: `{ Weekday = 7; Hour = 3; Minute = 15; }`) - GC schedule
- `garbageCollection.options` (string, default: `"--delete-older-than 30d"`) - GC options
- `optimizeStore` (bool, default: `true`) - Enable automatic store optimization
- `extraSubstituters` (list of strings, default: `[]`) - Additional binary cache URLs
- `extraPublicKeys` (list of strings, default: `[]`) - Additional trusted public keys

**Provides:**
- Nix daemon configuration with flakes enabled
- Binary cache configuration (NixOS cache + nix-community)
- Automatic garbage collection and store optimization
- Trusted users management

**Example:**
```nix
darwin.nix-settings = {
  enable = true;
  trustedUsers = [ "jrudnik" "admin" ];
  garbageCollection = {
    automatic = true;
    options = "--delete-older-than 14d";  # More aggressive
  };
  extraSubstituters = [ "https://example.cachix.org" ];
};
```

---

### `darwin.system-defaults`

macOS system preferences and defaults.

```nix
darwin.system-defaults = {
  enable = true;                    # Enable system defaults
  dock = {
    autohide = true;                # Auto-hide dock
    orientation = "bottom";         # Dock position
    showRecents = false;            # Show recent apps
  };
  finder = {
    showAllExtensions = true;       # Show file extensions
    showPathbar = true;             # Show path bar
    showStatusBar = true;           # Show status bar
  };
  globalDomain = {
    disableAutomaticCapitalization = true;     # Disable auto-caps
    disableAutomaticSpellingCorrection = true; # Disable auto-correct
    expandSavePanel = true;         # Expand save dialogs
  };
};
```

**Options:**

**`dock`:**
- `autohide` (bool, default: `true`) - Automatically hide the dock
- `orientation` (enum: "bottom"|"left"|"right", default: `"bottom"`) - Dock position
- `showRecents` (bool, default: `false`) - Show recent applications in dock

**`finder`:**
- `showAllExtensions` (bool, default: `true`) - Show all file extensions
- `showPathbar` (bool, default: `true`) - Show path bar in Finder
- `showStatusBar` (bool, default: `true`) - Show status bar in Finder

**`globalDomain`:**
- `disableAutomaticCapitalization` (bool, default: `true`) - Disable automatic capitalization
- `disableAutomaticSpellingCorrection` (bool, default: `true`) - Disable automatic spelling correction
- `expandSavePanel` (bool, default: `true`) - Expand save panels by default

**Provides:**
- macOS dock configuration
- Finder behavior and appearance
- Global text input settings
- Save/print dialog preferences

**Example:**
```nix
darwin.system-defaults = {
  enable = true;
  dock = {
    autohide = false;               # Keep dock visible
    orientation = "left";           # Left-side dock
  };
  finder.showPathbar = false;       # Hide path bar
};
```

---

## Home Manager Modules

### `home.shell`

Zsh configuration with oh-my-zsh and aliases.

```nix
home.shell = {
  enable = true;                    # Enable shell configuration
  aliases = {};                     # Custom aliases
  ohMyZsh = {
    theme = "robbyrussell";         # Oh-my-zsh theme
    plugins = [ "git" "macos" ];    # Oh-my-zsh plugins
  };
  enableNixShortcuts = true;        # Enable Nix shortcuts
  configPath = "~/nix-config";      # Path to nix config
  hostName = "parsley";             # Host name for shortcuts
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable shell configuration
- `aliases` (attrs of strings, default: `{}`) - Custom shell aliases
- `ohMyZsh.theme` (string, default: `"robbyrussell"`) - Oh-my-zsh theme
- `ohMyZsh.plugins` (list of strings, default: `[ "git" "macos" ]`) - Oh-my-zsh plugins
- `enableNixShortcuts` (bool, default: `true`) - Enable convenient Nix shortcuts
- `configPath` (string, default: `"~/nix-config"`) - Path to nix configuration
- `hostName` (string, default: `"parsley"`) - Host name for nix shortcuts

**Provides:**
- Zsh with completion and oh-my-zsh
- Basic file operation aliases (ll, la, l, .., ...)
- Nix operation shortcuts (nrs, nrb, nfu, nfc, ngc)
- Direnv integration with nix-direnv

**Built-in Aliases:**
- `ll` → `ls -alF`
- `la` → `ls -A`
- `l` → `ls -CF`
- `..` → `cd ..`
- `...` → `cd ../..`
- `nrs` → `sudo darwin-rebuild switch --flake ~/nix-config#parsley`
- `nrb` → `darwin-rebuild build --flake ~/nix-config#parsley`
- `nfu` → `nix flake update`
- `nfc` → `nix flake check`
- `ngc` → `nix-collect-garbage -d && sudo nix-collect-garbage -d`

**Example:**
```nix
home.shell = {
  enable = true;
  aliases = {
    deploy = "cd ~/projects && ./deploy.sh";
    logs = "tail -f /var/log/system.log";
    weather = "curl wttr.in";
  };
  ohMyZsh = {
    theme = "agnoster";
    plugins = [ "git" "macos" "docker" "node" "rust" ];
  };
};
```

---

### `home.development`

Development environment and programming tools.

```nix
home.development = {
  enable = true;                    # Enable development environment
  languages = {
    rust = true;                    # Rust tools (rustc, cargo)
    go = true;                      # Go compiler
    python = true;                  # Python 3
    node = false;                   # Node.js and yarn
  };
  editor = "micro";                 # Default editor
  extraPackages = [];              # Additional packages
  utilities = {
    enableBasicUtils = true;        # tree, jq
    extraUtils = [];               # Additional utilities
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable development environment
- `languages.rust` (bool, default: `false`) - Enable Rust development tools
- `languages.go` (bool, default: `false`) - Enable Go development tools
- `languages.python` (bool, default: `false`) - Enable Python development tools
- `languages.node` (bool, default: `false`) - Enable Node.js development tools
- `editor` (enum: "micro"|"nano"|"vim"|"code", default: `"micro"`) - Default text editor
- `extraPackages` (list of packages, default: `[]`) - Additional development packages
- `utilities.enableBasicUtils` (bool, default: `true`) - Enable basic utilities (tree, jq)
- `utilities.extraUtils` (list of packages, default: `[]`) - Additional utility packages

**Provides:**
- Always: git, curl, wget, chosen editor
- Language-specific tools based on enabled languages
- Basic utilities: tree, jq (if enabled)
- EDITOR environment variable

**Language Tools:**
- **Rust**: `rustc`, `cargo`
- **Go**: `go`
- **Python**: `python3`
- **Node**: `nodejs`, `yarn`

**Example:**
```nix
home.development = {
  enable = true;
  languages = {
    rust = true;
    go = true;
    python = true;
    node = true;
  };
  editor = "code";
  extraPackages = with pkgs; [ docker kubectl terraform ];
  utilities = {
    enableBasicUtils = true;
    extraUtils = with pkgs; [ htop ripgrep fd bat ];
  };
};
```

---

### `home.git`

Git configuration and settings.

```nix
home.git = {
  enable = true;                    # Enable git configuration
  userName = "Your Name";           # Git user name
  userEmail = "you@example.com";    # Git user email
  defaultBranch = "main";           # Default branch name
  editor = "micro";                 # Git editor
  extraConfig = {};                # Additional git config
  aliases = {};                    # Git aliases
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Git configuration
- `userName` (string, **required**) - Git user name
- `userEmail` (string, **required**) - Git user email
- `defaultBranch` (string, default: `"main"`) - Default branch for new repositories
- `editor` (string, default: `"micro"`) - Default Git editor
- `extraConfig` (attrs, default: `{}`) - Additional Git configuration options
- `aliases` (attrs of strings, default: `{}`) - Git aliases

**Provides:**
- Git user configuration
- Sensible defaults (init.defaultBranch, pull.rebase = false, push.default = simple)
- Custom editor configuration
- Additional configuration and aliases

**Built-in Configuration:**
- `init.defaultBranch` → Set to `defaultBranch` option
- `core.editor` → Set to `editor` option
- `pull.rebase` → `false`
- `push.default` → `"simple"`

**Example:**
```nix
home.git = {
  enable = true;
  userName = "John Doe";
  userEmail = "john.doe@company.com";
  defaultBranch = "main";
  editor = "code --wait";
  
  extraConfig = {
    diff.tool = "vscode";
    merge.tool = "vscode";
    core.autocrlf = "input";
  };
  
  aliases = {
    st = "status";
    co = "checkout";
    br = "branch";
    ci = "commit";
    unstage = "reset HEAD --";
    visual = "!gitk";
  };
};
```

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
  };
  
  nix-settings = {
    enable = true;
    trustedUsers = [ "developer" "admin" ];
    garbageCollection.options = "--delete-older-than 14d";
  };
  
  system-defaults = {
    enable = true;
    dock = {
      autohide = false;
      orientation = "left";
    };
    finder.showStatusBar = false;
  };
};

home = {
  shell = {
    enable = true;
    aliases = {
      deploy = "cd ~/projects && ./deploy.sh";
      k = "kubectl";
      tf = "terraform";
    };
    ohMyZsh = {
      theme = "agnoster";
      plugins = [ "git" "macos" "docker" "kubectl" "terraform" ];
    };
  };
  
  development = {
    enable = true;
    languages = {
      rust = true;
      go = true;
      python = true;
      node = true;
    };
    editor = "code";
    extraPackages = with pkgs; [ docker kubectl terraform ];
  };
  
  git = {
    enable = true;
    userName = "Developer Name";
    userEmail = "dev@company.com";
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
    };
  };
};
```

This reference provides complete documentation of all available options in each module, making it easy to customize your configuration exactly how you want it.