{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    outputs.homeManagerModules.editors
    outputs.homeManagerModules.window-manager
    outputs.homeManagerModules.security
    outputs.homeManagerModules.ai
    outputs.homeManagerModules.raycast
    outputs.homeManagerModules.syncthing
    outputs.homeManagerModules.thunderbird
    outputs.homeManagerModules.sketchybar
    # mcp module removed - using mcp-servers-nix directly
    

  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
    
    # User-level GUI applications
    packages = with pkgs; [
      psst  # Fast Spotify client with native GUI
    ];
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Additional packages - most packages managed via modules
  
  # Note: nixpkgs config is managed globally via useGlobalPkgs in flake.nix
  
  # Stylix targets - expand theming to more applications
  # Note: Only enabling targets that are commonly available across platforms
  stylix.targets = {
    # Terminal emulators
    alacritty.enable = true;
    
    # CLI tools - these are well-supported
    bat.enable = true;
    btop.enable = true;
    fzf.enable = true;
    
    # Development tools
    vim.enable = true;
    neovim.enable = true;
    
    # Git tools
    lazygit.enable = true;
    
    # GTK applications (limited effect on macOS)
    gtk.enable = true;
    
    # Note: Shell theming (zsh) is handled by our shell module
    # Note: Zed theming is handled by home.editors.zed.theme via mkDefault
  };

  # Module configuration
  home = {
    editors = {
      zed = {
        enable = true;
        extensions = [
          "nix"              # Nix language support
          "toml"             # TOML syntax highlighting
          "dockerfile"       # Docker support
          "html"             # HTML support
          "make"             # Makefile support
          "markdown"         # Markdown preview
          "yaml"             # YAML syntax
          "rust"             # Rust language (if using)
        ];
        enableGitHubCopilot = false;  # Set to true + manual OAuth if you use Copilot
        theme = "Gruvbox Dark Hard";   # Matches your system theme
        fontSize = 14;
      };
    };
    shell = {
      enable = true;

      # Nix operation shortcuts (nrs, nrb, nfu, etc.)
      nixShortcuts = {
        enable = true;
        configPath = "~/nix-config";
        hostName = "parsley";
      };
      
      # Modern CLI tools (eza, bat, ripgrep, fd, zoxide)
      modernTools = {
        enable = true;
        replaceLegacy = true;  # ls→eza, cat→bat, grep→rg, etc.
      };
      
      # Custom aliases (highest priority)
      aliases = {
        # Git utilities
        lg = "lazygit";  # Simple terminal UI for git commands
      };
      
      # Backend: Zsh with Oh-My-Zsh (default implementation)
      # To use Zsh-specific features, configure:
      # implementation.zsh.theme = "robbyrussell";  # Default theme
      # implementation.zsh.plugins = [ "git" "macos" ];  # Default plugins
    };
    
    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
      };
      editor = "micro";
      neovim = false;  # Alternative: Neovim with automatic theming
      
      # Enable GitHub CLI with shell completion
      github.enable = true;
      
      # Git utilities
      utilities.lazygit = true;  # Simple terminal UI for git commands
    };
    
    git = {
      enable = true;
      userName = "jrudnik";
      userEmail = "john.rudnik@gmail.com";
      
      # Git aliases: Choose one approach:
      # Option 1: Use comprehensive built-in aliases (38 curated shortcuts)
      # aliases = {};  # Empty = use built-in productivity aliases
      
      # Option 2: Custom aliases (overrides all built-in aliases)
      aliases = {
        # Essential shortcuts
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        
        # Workflow shortcuts
        pushf = "push --force-with-lease";
        unstage = "reset HEAD --";
        amend = "commit --amend";
        undo = "reset --soft HEAD~1";
        last = "log -1 HEAD";
        visual = "log --oneline --graph --decorate --all";
        
        # Branch management
        recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'";
        
        # Handy workflows
        please = "push --force-with-lease";
        commend = "commit --amend --no-edit";
      };
      # To see all built-in aliases, check: docs/module-options.md
    };
    
    cli-tools = {
      enable = true;
      
      # Optional: Modern system monitor (btop has beautiful Stylix theming)
      systemMonitor = "btop";  # Options: "none", "htop", "btop"
    };
    
    # Starship cross-shell prompt configuration
    starship = {
      enable = true;
      theme = "gruvbox-rainbow";  # Options: gruvbox-rainbow, minimal, nerd-font-symbols
      showLanguages = [ "nodejs" "rust" "golang" "python" "nix_shell" ];
      showSystemInfo = true;
      showTime = true;
      showBattery = true;
      cmdDurationThreshold = 4000;
    };
    
    # Apps appear in standard locations automatically:
    # - Home Manager apps: ~/Applications/Home Manager Apps
    # - nix-darwin system apps: /Applications/Nix Apps
    
    window-manager = {
      enable = true;
      # Abstract window manager configuration:
      # - Alt-based keybindings (default)
      # - Clean window gaps and layout (8px)
      # - Warp terminal integration (Alt+Enter)
      # - Zen Browser integration (Alt+B)
      # - Bitwarden integration (Alt+P)
      # Backend: AeroSpace (default implementation)
      # To use AeroSpace-specific features, configure:
    # implementation.aerospace.extraConfig = ''...''
    };
    raycast = {
      enable = true;
    };
    
    syncthing = {
      enable = true;
      autoStart = true;  # Start automatically at login
      openWebUI = false; # Don't auto-open web UI (access at http://127.0.0.1:8384)
    };
    
    thunderbird = {
      enable = true;
      
      # Define a default profile
      profiles.default = {
        isDefault = true;
        settings = {
          # Add any custom Thunderbird preferences here
          # Example: "mail.server.default.check_new_mail" = true;
        };
      };
      
      # Privacy settings
      privacy = {
        enableDoNotTrack = true;
        disableTelemetry = true;
      };
      
      # Features
      features = {
        enableOpenPGP = true;
        enableCalendar = true;
        compactFolders = true;
      };
      
      # Appearance
      appearance = {
        theme = "auto";  # Follows system light/dark mode
        fontSize = 14;
      };
    };
    
    sketchybar = {
      enable = true;
      position = "top";  # Replace macOS menu bar
      height = 32;  # Standard menu bar height
      font = "SF Pro";  # System font, clean and modern
      
      # AeroSpace workspace integration
      aerospace = {
        enable = true;
        workspaces = [ "1" "2" "3" "4" "5" ];  # Match your AeroSpace workspaces
      };
      
      # Widget configuration
      showCalendar = true;   # Date/time widget
      showBattery = true;    # Battery indicator
      showWifi = true;       # WiFi status
      showVolume = true;     # Volume control
      showCpu = true;        # CPU usage
      
      # Color scheme (will be themed by Stylix automatically)
      colors = {
        bar = "0xff1e1e2e";  # Semi-transparent dark background
        icon = "0xffcad3f5";  # Light icon color
        label = "0xffcad3f5";  # Light label color
        workspaceActive = "0xffed8796";  # Highlight color for active workspace
        workspaceInactive = "0x44ffffff";  # Subtle inactive workspace background
      };
    };
    
  };
  
  # MCP (Model Context Protocol) servers configuration using mcp-servers-nix
  # This generates the configuration file for Claude Desktop (and claude-code automatically)
  home.file."Library/Application Support/Claude/claude_desktop_config.json".source =
    inputs.mcp-servers-nix.lib.mkConfig pkgs {
      # Uses "claude" flavor by default - generates standard Claude Desktop format
      programs = {
        # Filesystem access - official MCP server from mcp-servers-nix
        filesystem = {
          enable = true;
          args = [ config.home.homeDirectory ];  # Allow access to home directory
        };
        
        # GitHub integration - official server (works read-only without token)
        github.enable = true;
        # To add GitHub token securely:
        # github.passwordCommand.GITHUB_TOKEN = [ "gh" "auth" "token" ];
        
        # Git operations - safe, no secrets required
        git.enable = true;
        
        # Time utilities - safe, no secrets required
        time.enable = true;
        
        # Web fetch capability - safe, no secrets required
        fetch.enable = true;
      };
    };
  
  # Security/Password Manager configuration
  # WARP LAW 4.3 COMPLIANCE:
  # - Bitwarden GUI: Installed via nix-darwin in hosts/parsley/configuration.nix
  # - Configuration: Managed here via home-manager
  home.security = {
    enable = true;
    
    # Abstract password manager options
    autoStart = false;  # Set to true to start at login
    unlockMethod = "biometric";  # Use Touch ID for unlock
    lockTimeout = 15;  # Auto-lock after 15 minutes
    windowBehavior = "minimize-to-tray";  # Minimize to tray instead of closing
    startBehavior = "normal";  # Start with visible window
    
    # Backend: Bitwarden (default implementation)
    # To use Bitwarden-specific features, configure:
    # implementation.bitwarden.cli.enable = true;  # Enable CLI tool
  };
  
  # AI tools configuration
  programs = {
    # Secret management (macOS Keychain integration)
    ai.secrets = {
      enable = true;  # Enable to use keychain for API keys
      shellIntegration = true;  # Auto-source secrets in shell
    };
    
    # Code Analysis & Prompt Generation
    code2prompt.enable = true;        # ✅ Code → prompt converter
    files-to-prompt.enable = true;    # ✅ Files → prompt converter
    goose-cli.enable = false;         # Disabled (requires API keys)
    
    # AI Productivity Patterns - using nixpkgs module
    fabric-ai = {                     # ✅ Fabric AI productivity patterns
      enable = true;
      enablePatternsAliases = true;   # Create shell aliases for all patterns
      enableYtAlias = true;           # Enable YouTube transcript helper
    };
    
    # LLM Interfaces - using nixpkgs built-in modules
    github-copilot-cli.enable = true; # ✅ GitHub Copilot CLI
    claude-desktop.enable = false;    # Claude Desktop (Homebrew cask)
    
    # AI CLI tools - direct nixpkgs modules (no custom wrappers needed)
    claude-code.enable = true;        # ✅ Claude Code terminal (from nixpkgs)
    gemini-cli.enable = true;         # ✅ Gemini CLI (from nixpkgs)
    
    # Diagnostics tool
    ai.diagnostics.enable = true;
  };
  
  # Note: MCP servers configured via mcp-servers-nix (see lines 178-204)
  
  # XDG directories
  xdg.enable = true;
  
  # Link custom Fabric AI patterns (task definitions)
  xdg.configFile."fabric/patterns" = {
    source = ./../../modules/home/ai/patterns/fabric/tasks;
    recursive = true;
  };
  
}
