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
  # home.packages = with pkgs; [ ];
  
  # Note: nixpkgs config is managed globally via useGlobalPkgs in flake.nix

  # Module configuration
  home = {
    shell = {
      enable = true;
      configPath = "~/nix-config";
      hostName = "parsley";
      # Can add custom aliases here if needed
      aliases = {
        # Example: deploy = "cd ~/projects && ./deploy.sh";
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
      # Includes: eza, bat, ripgrep, fd, zoxide, fzf, starship, alacritty
      
      # Optional: Modern system monitor (btop has beautiful Stylix theming)
      systemMonitor = "btop";  # Options: "none", "htop", "btop"
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
  
  # XDG directories
  xdg.enable = true;
}
