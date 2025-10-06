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

### `darwin.homebrew`

Homebrew package management via nix-homebrew.

```nix
darwin.homebrew = {
  enable = true;                    # Enable Homebrew management
  brews = [];                       # Homebrew formulae to install
  casks = [ "warp" "firefox" ];      # Homebrew casks to install
  masApps = {};                     # Mac App Store apps
  onActivation = {
    autoUpdate = false;             # Auto-update Homebrew
    upgrade = false;                # Upgrade packages on activation
    cleanup = "none";               # Cleanup strategy
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Homebrew package management
- `brews` (list of strings, default: `[]`) - List of Homebrew formulae to install
- `casks` (list of strings, default: `[]`) - List of Homebrew casks to install
- `masApps` (attrs of ints, default: `{}`) - Mac App Store apps (name = app store id)
- `onActivation.autoUpdate` (bool, default: `false`) - Auto-update Homebrew and packages
- `onActivation.upgrade` (bool, default: `false`) - Upgrade packages on activation
- `onActivation.cleanup` (enum: "none"|"uninstall"|"zap", default: `"none"`) - Cleanup strategy

**Provides:**
- Declarative Homebrew formula management
- Homebrew cask installation for GUI applications
- Mac App Store app installation
- Cleanup and maintenance automation

**Example:**
```nix
darwin.homebrew = {
  enable = true;
  casks = [ "warp" "firefox" "docker" "visual-studio-code" ];
  masApps = {
    "Xcode" = 497799835;
    "1Password 7" = 1333542190;
  };
  onActivation = {
    cleanup = "uninstall";  # Remove unlisted packages
  };
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

*Basic File Operations:*
- `ll` → `ls -alF`
- `la` → `ls -A`
- `l` → `ls -CF`
- `..` → `cd ..`
- `...` → `cd ../..`

*Nix Operations:*
- `nrs` → `sudo darwin-rebuild switch --flake ~/nix-config#parsley`
- `nrb` → `darwin-rebuild build --flake ~/nix-config#parsley`
- `nfu` → `nix flake update`
- `nfc` → `nix flake check`
- `ngc` → `nix-collect-garbage -d && sudo nix-collect-garbage -d`

*Productivity Aliases:*
- `c` → `clear`
- `h` → `history`
- `j` → `jobs`
- `reload` → `exec zsh`
- `path` → `echo $PATH | tr : '
'`
- `mkdir` → `mkdir -p`
- `ping` → `ping -c 5`
- `df` → `df -h`
- `du` → `du -h`
- `free` → `vm_stat`
- `ps` → `ps aux`
- `top` → `top -o cpu`
- `ports` → `sudo lsof -i -P -n | grep LISTEN`
- `myip` → `curl -s ifconfig.me`
- `localip` → `ipconfig getifaddr en0`
- `edit` → `$EDITOR`
- `cat` → `bat` (if bat is installed)
- `grep` → `rg` (if ripgrep is installed)
- `find` → `fd` (if fd is installed)
- `ls` → `eza --icons --git` (if eza is installed)

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
- `github.enable` (bool, default: `false`) - Enable GitHub CLI and authentication

**Provides:**
- Always: git, curl, wget, chosen editor
- Language-specific tools based on enabled languages
- Basic utilities: tree, jq (if enabled)
- EDITOR environment variable
- GitHub CLI (gh) when enabled with shell completion

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
  github.enable = true;  # Enable GitHub CLI
};
```

---

### `home.cli-tools`

Modern CLI tools collection with shell integration.

```nix
home.cli-tools = {
  enable = true;                    # Enable CLI tools collection
  enableShellIntegration = true;    # Enable shell integration for tools
  fileManager = {
    eza = true;                     # Modern ls replacement (eza)
    zoxide = true;                  # Smart directory navigation (zoxide)
    fzf = true;                     # Fuzzy finder (fzf)
  };
  textTools = {
    bat = true;                     # Syntax-highlighted cat (bat)
    ripgrep = true;                 # Fast text search (ripgrep)
    fd = true;                      # Fast find alternative (fd)
  };
  prompt = {
    starship = true;                # Cross-shell prompt (starship)
  };
  terminals = {
    alacritty = true;               # GPU-accelerated terminal (alacritty)
    warp = false;                   # Warp terminal (managed via Homebrew cask)
  };
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable modern CLI tools collection
- `enableShellIntegration` (bool, default: `true`) - Enable shell integration for CLI tools
- `fileManager.eza` (bool, default: `true`) - Enable eza (modern ls replacement)
- `fileManager.zoxide` (bool, default: `true`) - Enable zoxide (smart directory navigation)
- `fileManager.fzf` (bool, default: `true`) - Enable fzf (fuzzy finder)
- `textTools.bat` (bool, default: `true`) - Enable bat (syntax-highlighted cat)
- `textTools.ripgrep` (bool, default: `true`) - Enable ripgrep (fast text search)
- `textTools.fd` (bool, default: `true`) - Enable fd (fast find alternative)
- `prompt.starship` (bool, default: `true`) - Enable starship (cross-shell prompt)
- `terminals.alacritty` (bool, default: `true`) - Enable alacritty (GPU terminal)
- `terminals.warp` (bool, default: `false`) - Enable warp terminal (managed via Homebrew)

**Provides:**
- File management: `eza` (ls replacement), `zoxide` (smart cd), `fzf` (fuzzy finder)
- Text processing: `bat` (cat with syntax highlighting), `ripgrep` (fast grep), `fd` (fast find)
- Shell enhancement: `starship` (modern prompt)
- Terminal applications: `alacritty` (GPU-accelerated terminal)
- Shell integration for supported tools (configurable)

**Built-in Configurations:**
- **Eza**: Git integration, icons, colors
- **Zoxide**: Zsh integration handled manually in shell module
- **Fzf**: Integration with fd for file searching
- **Bat**: Syntax highlighting with base16 theme
- **Starship**: Minimal, fast prompt configuration
- **Alacritty**: macOS-optimized settings with zsh integration

**Example:**
```nix
home.cli-tools = {
  enable = true;
  enableShellIntegration = true;
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
  prompt.starship = true;
  terminals = {
    alacritty = false;  # Disable if using different terminal
    warp = false;       # Managed via Homebrew cask
  };
};
```

---

### `home.spotlight`

Enhanced Spotlight integration for Nix applications.

```nix
home.spotlight = {
  enable = true;                    # Enable Spotlight integration
  appsFolder = "Applications/HomeManager"; # Folder name for apps (avoid spaces)
  forceReindex = true;              # Auto-reindex Spotlight after changes
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable enhanced Spotlight integration
- `appsFolder` (string, default: `"Applications/HomeManager"`) - Folder name in ~/Applications for home-manager apps
- `forceReindex` (bool, default: `true`) - Force Spotlight to reindex applications after activation

**Provides:**
- Creates organized application links in `~/Applications/` for Spotlight discovery
- Automatic Spotlight reindexing after configuration changes
- Better folder naming (without spaces) for improved indexing
- Session variables for GUI application resource discovery
- User feedback during activation about indexing status

**How it works:**
- Replaces the default "Home Manager Apps" folder with a cleaner named folder
- Uses `buildEnv` with `pathsToLink = "/Applications"` to create proper symlinks
- Triggers Spotlight reindexing using `mdutil` commands
- Provides clear feedback about indexing status and timing

**Example:**
```nix
home.spotlight = {
  enable = true;
  appsFolder = "Applications/NixApps";  # Custom folder name
  forceReindex = true;  # Ensure Spotlight finds new apps
};
```

**Troubleshooting:**
- Applications typically appear in Spotlight within 2-5 minutes after activation
- Manual reindexing: `mdutil -E ~/Applications`
- Check indexing status: `mdutil -s ~/Applications`
- Verify links exist: `ls -la ~/Applications/[your-apps-folder]/`

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
- Curated productivity aliases for common workflows

**Built-in Configuration:**
- `init.defaultBranch` → Set to `defaultBranch` option
- `core.editor` → Set to `editor` option
- `pull.rebase` → `false`
- `push.default` → `"simple"`

**Built-in Aliases (when aliases = {})**:
- `st` → `status --short --branch`
- `s` → `status --short`
- `co` → `checkout`
- `sw` → `switch`
- `br` → `branch`
- `ci` → `commit`
- `cm` → `commit -m`
- `ca` → `commit --amend`
- `can` → `commit --amend --no-edit`
- `d` → `diff`
- `ds` → `diff --staged`
- `dt` → `difftool`
- `mt` → `mergetool`
- `cp` → `cherry-pick`
- `rb` → `rebase`
- `rbi` → `rebase -i`
- `rbc` → `rebase --continue`
- `rba` → `rebase --abort`
- `f` → `fetch`
- `fa` → `fetch --all`
- `fp` → `fetch --prune`
- `pl` → `pull`
- `ps` → `push`
- `psu` → `push -u origin HEAD`
- `psf` → `push --force-with-lease`
- `lg` → `log --oneline --graph --decorate`
- `lga` → `log --oneline --graph --decorate --all`
- `ll` → `log --pretty=format:'%C(yellow)%h%Creset %ad %Cgreen%an%Creset %s' --date=relative`
- `today` → `log --since='6am' --oneline --author='$(git config user.email)'`
- `yesterday` → `log --since='yesterday' --until='6am' --oneline --author='$(git config user.email)'`
- `week` → `log --since='1 week ago' --oneline --author='$(git config user.email)'`
- `standup` → `log --since='yesterday' --until='6am' --oneline --author='$(git config user.email)'`
- `unstage` → `reset HEAD --`
- `uncommit` → `reset --soft HEAD~1`
- `amend` → `commit --amend --reuse-message=HEAD`
- `undo` → `reset HEAD~1 --mixed`
- `tree` → `log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit`
- `aliases` → `config --get-regexp '^alias\.'`

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
  
  # Custom aliases (overrides built-in ones)
  aliases = {
    please = "push --force-with-lease";
    commend = "commit --amend --no-edit";
    it = "!git init && git add . && git commit -m 'Initial commit'";
    stash-all = "stash save --include-untracked";
    grog = "log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'";
  };
};
```

**Note:** When `aliases = {}` (empty), the module provides a comprehensive set of built-in productivity aliases. When you define custom aliases, they completely override the built-in set, so include any built-in aliases you want to keep.

---

### `home.raycast`

Raycast launcher configuration.

```nix
home.raycast = {
  enable = true;                    # Enable Raycast launcher
  package = pkgs.raycast;           # Raycast package
  followSystemAppearance = true;    # Follow system theme
  globalHotkey = {
    keyCode = 49;                   # Key code (49 = Space)
    modifierFlags = 1048576;        # Modifier (1048576 = Cmd)
  };
  extraDefaults = {};              # Additional preferences
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable Raycast launcher installed and configured declaratively
- `package` (package, default: `pkgs.raycast`) - Raycast application package from nixpkgs (unfree)
- `followSystemAppearance` (bool, default: `true`) - Follow system appearance for light/dark mode
- `globalHotkey` (nullOr submodule, default: `{ keyCode = 49; modifierFlags = 1048576; }`) - Global hotkey configuration
  - `keyCode` (int) - Key code for the global hotkey (49 = space, 36 = return)
  - `modifierFlags` (int) - Modifier flags (1048576 = Cmd, 524288 = Option, 262144 = Ctrl, 131072 = Shift)
- `extraDefaults` (attrsOf (oneOf [ bool int float str ]), default: `{}`) - Additional com.raycast.macos defaults

**Provides:**
- Raycast application installed via nixpkgs (requires unfree packages allowed)
- Declarative preference configuration via macOS defaults
- Automatic Spotlight shortcut disabling (Cmd+Space, Cmd+Option+Space)
- Global hotkey configuration for Raycast activation

**Platform Requirements:**
- macOS only (includes Darwin platform assertion)
- Unfree packages must be allowed via `allowUnfreePredicate`

**Configuration Keys:**
- Maps `followSystemAppearance` → `com.raycast.macos.raycastShouldFollowSystemAppearance`
- Maps `globalHotkey` → `com.raycast.macos.raycastGlobalHotkey`
- Enables hotkey monitoring and skips onboarding dialogs

**Example:**
```nix
home.raycast = {
  enable = true;
  followSystemAppearance = true;
  globalHotkey = {
    keyCode = 49;           # Space key
    modifierFlags = 1048576; # Command modifier
  };
  extraDefaults = {
    "onboarding_setupHotkey" = true;
  };
};
```

**Limitations:**
- Only simple hotkey combinations supported via typed interface
- Extension management not supported
- Complex nested preferences require `extraDefaults`
- Settings apply on next Raycast launch, not immediately

---

### `home.mcp`

Model Context Protocol (MCP) servers for Claude Desktop.

```nix
home.mcp = {
  enable = true;                    # Enable MCP server configuration
  servers = {
    filesystem = {
      command = "${pkgs.python3}/bin/python3";
      args = [ "./filesystem-server.py" "/Users/username" ];
      env = {};
    };
    git = {
      command = "${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
      args = [];
      env = {};
    };
  };
  configPath = "Library/Application Support/Claude/claude_desktop_config.json";
  additionalConfig = {};           # Additional Claude Desktop config
};
```

**Options:**
- `enable` (bool, default: `false`) - Enable MCP servers for Claude Desktop
- `servers` (attrsOf submodule, default: `{}`) - Attribute set of MCP server configurations
- `configPath` (string, default: `"Library/Application Support/Claude/claude_desktop_config.json"`) - Relative path from home directory to Claude Desktop MCP config
- `additionalConfig` (attrs, default: `{}`) - Additional configuration to merge into Claude Desktop config

**Server Submodule Options:**
- `command` (string, **required**) - Absolute path to server binary (prefer Nix store path)
- `args` (listOf string, default: `[]`) - Arguments to pass to the MCP server
- `env` (attrsOf string, default: `{}`) - Environment variables for the server

**Provides:**
- Declarative MCP server configuration for Claude Desktop
- Automatic generation of Claude Desktop configuration JSON
- Integration with `mcp-servers-nix` package overlay
- Support for custom servers and environment variables

**Default Servers:**
- **filesystem**: Custom Python-based file operations (home directory access only)
- **github**: GitHub API integration (requires GITHUB_TOKEN for private repos)
- **git**: Local git repository operations
- **time**: Date, time, and timezone utilities
- **fetch**: HTTP/HTTPS web requests

**Security Features:**
- Path restrictions for filesystem server (home directory only)
- Safe server selection (no secrets required by default)
- Optional environment variable support for API keys
- All server binaries use Nix store paths for reproducibility

**Example:**
```nix
home.mcp = {
  enable = true;
  servers = {
    # Safe filesystem access
    filesystem = {
      command = "${pkgs.python3}/bin/python3";
      args = [ "${config.home.homeDirectory}/nix-config/modules/home/mcp/filesystem-server.py" "${config.home.homeDirectory}" ];
    };
    
    # GitHub integration with API token
    github = {
      command = "${pkgs.github-mcp-server}/bin/server";
      env = {
        GITHUB_TOKEN = "ghp_your_token_here";  # In practice, use secrets
      };
    };
    
    # Git operations (no configuration needed)
    git = {
      command = "${pkgs.mcp-servers.mcp-server-git}/bin/mcp-server-git";
    };
    
    # Custom server example
    custom = {
      command = "${pkgs.my-custom-server}/bin/server";
      args = [ "--config" "/path/to/config.json" ];
      env = {
        DEBUG = "1";
        API_ENDPOINT = "https://api.example.com";
      };
    };
  };
  
  # Additional Claude Desktop configuration
  additionalConfig = {
    # Future: other Claude Desktop settings
  };
};
```

**Testing Servers:**
```bash
# Test any MCP server manually
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"roots": {"listChanged": true}}, "clientInfo": {"name": "test", "version": "1.0.0"}}}' | /path/to/mcp-server
```

**Related Documentation:**
- [MCP Integration Guide](./mcp-integration.md) - Complete setup and usage documentation
- [AI Tools Inventory](./ai/INVENTORY.md) - Available MCP tools in nixpkgs

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