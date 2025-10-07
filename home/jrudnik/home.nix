{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.homeManagerModules.shell
    outputs.homeManagerModules.development
    outputs.homeManagerModules.git
    outputs.homeManagerModules.cli-tools
    # Spotlight module removed - using Raycast for app launching
    outputs.homeManagerModules.window-manager
    outputs.homeManagerModules.raycast
    outputs.homeManagerModules.browser
    outputs.homeManagerModules.security
    outputs.homeManagerModules.ai
    # MCP module removed - using mcp-servers-nix directly
    
    # macOS-specific modules
    outputs.homeManagerModules.macos.launchservices
    outputs.homeManagerModules.macos.keybindings
  ];

  # Home Manager configuration
  home = {
    username = "jrudnik";
    homeDirectory = "/Users/jrudnik";
    stateVersion = "25.05";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Additional packages - most packages managed via modules
  home.packages = with pkgs; [
    warp-terminal  # Modern terminal with AI features (unfree, managed via Home Manager)
  ];
  
  # Note: nixpkgs config is managed globally via useGlobalPkgs in flake.nix

  # Module configuration
  home = {
    shell = {
      enable = true;
      configPath = "~/nix-config";
      hostName = "parsley";
      # Can add custom aliases here if needed
      aliases = {
        # Git utilities
        lg = "lazygit";  # Simple terminal UI for git commands
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
      # Optional: Enable Emacs - it has excellent Stylix theming support!
      emacs = true;    # Emacs with automatic Stylix theming enabled!
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
      # All modern CLI tools with sensible defaults
      # Includes: eza, bat, ripgrep, fd, zoxide, fzf, alacritty (starship now separate)
      
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
    
    # Spotlight module removed - using Raycast for app launching
    # Apps appear in standard locations automatically:
    # - Home Manager apps: ~/Applications/Home Manager Apps
    # - nix-darwin system apps: /Applications/Nix Apps
    
    window-manager.aerospace = {
      enable = true;
      # Uses the default configuration from the module with:
      # - Alt-based keybindings
      # - Clean window gaps and layout
      # - Warp terminal integration (Alt+Enter)
    };
    
    raycast = {
      enable = true;
      followSystemAppearance = true;
      globalHotkey = {
        keyCode = 49;        # Space key
        modifierFlags = 1048576;  # Command modifier (Cmd+Space)
      };
    };
    
    browser.zen = {
      enable = true;
      setAsDefaultBrowser = true;
      
      # Privacy-focused settings
      settings = {
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "browser.shell.checkDefaultBrowser" = false;
        "privacy.donottrackheader.enabled" = true;
        "browser.search.defaultenginename" = "DuckDuckGo";
        
        # Enhanced privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "network.cookie.sameSite.laxByDefault" = true;
        
        # Security settings
        "security.tls.version.min" = 3;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        
        # Performance tweaks
        "browser.sessionstore.interval" = 30000;  # Save session every 30s instead of 15s
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
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
  
  # Security configuration
  home.security.bitwarden = {
      enable = true;
      
      # macOS-specific settings
      enableTouchID = true;
      minimizeToTray = true;
      startMinimized = false;
      autoStart = false;  # Set to true if you want it to start at login
      
      # Security settings
      lockTimeout = 15;  # Auto-lock after 15 minutes
      
      # CLI integration disabled by default (bitwarden-cli package is broken)
      cli.enable = false;
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
  
  # Stylix theming configuration
  stylix.targets.zen-browser = {
    profileNames = [ "default" ];  # Tell Stylix to theme the default profile
  };
  
  # macOS-specific configuration
  home.macos = {
    # Centralized Launch Services (default applications)
    launchservices = {
      enable = true;
      
      # Additional manual LSHandlers (Zen Browser handlers are added automatically)
      handlers = [
        # Set text files to open with micro via terminal
        {
          LSHandlerContentType = "public.plain-text";
          LSHandlerRoleAll = "com.apple.Terminal";  # Opens in terminal, where micro is available
        }
        {
          LSHandlerContentTag = "nix";
          LSHandlerContentTagClass = "public.filename-extension";
          LSHandlerRoleAll = "com.apple.Terminal";
        }
        {
          LSHandlerContentTag = "md";
          LSHandlerContentTagClass = "public.filename-extension";
          LSHandlerRoleAll = "com.apple.Terminal";
        }
        # Python files
        {
          LSHandlerContentTag = "py";
          LSHandlerContentTagClass = "public.filename-extension";
          LSHandlerRoleAll = "com.apple.Terminal";
        }
      ];
    };
    
    # macOS keyboard and hotkey configuration
    keybindings = {
      enable = true;
      keyRepeat = 2;  # Fast key repeat
      initialKeyRepeat = 15;  # Short initial delay
      # Note: Spotlight hotkeys are already disabled by Raycast module
    };
  };
}
