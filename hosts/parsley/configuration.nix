{ config, pkgs, lib, inputs, outputs, ... }:

{
  imports = [
    outputs.darwinModules.core
    outputs.darwinModules.security
    outputs.darwinModules.nix-settings
    outputs.darwinModules.system-settings
    outputs.darwinModules.homebrew
    outputs.darwinModules.theming
    outputs.darwinModules.fonts
    outputs.darwinModules.raycast
  ];

  # Applications - Installed at system level per WARP LAW 4.3
  # "If it has a .app bundle, nix-darwin should install it"
  environment.systemPackages = with pkgs; [
    # === GUI Applications ===
    
    # Editors & IDEs
    emacs
    zed-editor
    
    # Terminals
    alacritty
    warp-terminal
    
    # Browsers
    zen-browser
    
    # Communication
    thunderbird     # Email client
    
    # Productivity & Documents
    skimpdf         # PDF reader and note-taker for macOS
    
    # Media & Entertainment
    vlc-bin-universal  # VLC media player (universal binary for macOS)
    
    # Security & Privacy
    bitwarden       # Password manager (configuration via home-manager)
    
    # Utilities
    flameshot       # Screenshot tool with annotations
    syncthing       # Continuous file synchronization
    
    # === CLI Tools ===
    
    # Modern Unix replacements
    eza             # Modern ls
    zoxide          # Smart cd
    fzf             # Fuzzy finder
    bat             # Better cat
    ripgrep         # Better grep
    fd              # Better find
    btop            # System monitor
    
    # Shell enhancements
    direnv          # Environment switcher
    atuin           # Shell history
    mcfly           # History search
    pay-respects    # Error correction
    delta           # Better diff
    
    # Development tools
    rustc
    cargo
    go
    python3
    nodejs
    micro           # Terminal text editor
    neovim          # Vim-based editor
    tree            # Directory visualization
    jq              # JSON processor
    lazygit         # Git TUI
    gh              # GitHub CLI
    
    # Image processing
    imagemagick     # Image manipulation CLI
  ];
  networking = {
    hostName = "parsley";
    computerName = "parsley";
    localHostName = "parsley";
  };

  # Module configuration
  darwin = {
    core.enable = true;
    
    security = {
      enable = true;
      primaryUser = "jrudnik";
      touchIdForSudo = true;
    };
    
    nix-settings = {
      enable = true;
      trustedUsers = [ "jrudnik" ];
    };
    
    system-settings = {
      enable = true;
      
      # Keyboard Pane - Settings that appear in System Settings > Keyboard
      keyboard = {
        keyRepeat = 2;              # Fast key repeat
        initialKeyRepeat = 15;      # Short initial delay
        pressAndHoldEnabled = false; # Disable accent menu, enable key repeat
        keyboardUIMode = 3;         # Full keyboard access
      };
      
      # Desktop & Dock Pane - Settings that appear in System Settings > Desktop & Dock
      desktopAndDock = {
        # Dock behavior
        dock = {
          autohide = true;
          autohideDelay = 0.0;  # Instant response
          autohideTime = 0.15;  # Quick animation
          orientation = "bottom";  # Bottom dock (change to "left" for left-side)
          showRecents = false;  # Clean dock without recent apps
          
          # Icon appearance
          magnification = true;
          tileSize = 45;  # Medium-sized icons
          largeSize = 70;  # Nice magnification size
          mineffect = "scale";  # Clean minimize effect
          minimizeToApp = true;  # Minimize to app icon
          launchanim = true;  # Keep app launch animation
          showProcessIndicators = true;  # Show running app indicators
          
          # Dock applications (customize these to your preferences)
          persistentApps = [
            # File Management & Navigation
            "/Applications/Nimble Commander.app"                          # Homebrew - Dual-pane file manager
            
            # Communication
            "/Applications/Nix Apps/Thunderbird.app"                      # System - Email client
            "/Applications/Beeper Desktop.app"                            # Homebrew - Universal chat
            
            # Browsers & Productivity
            "/Applications/Nix Apps/Zen Browser (Twilight).app"           # System - Web browser
            "/Applications/Nix Apps/Warp.app"                             # System - Terminal
            
            # Media & Entertainment
            "/Applications/Brain.fm.app"                                  # Homebrew - Focus music
            "${config.users.users.jrudnik.home}/Applications/Home Manager Apps/Psst.app"  # Home Manager - Spotify
            "/Applications/Nix Apps/VLC.app"                              # System - Media player
            
            # Research & Documents
            "/Applications/calibre.app"                                   # Homebrew - eBook management
            "/Applications/JabRef.app"                                    # Homebrew - Reference manager
            
            # Security & System
            "/Applications/Nix Apps/Bitwarden.app"                        # System - Password manager
            "/System/Applications/System Settings.app"                    # macOS - System preferences
          ];
          
          # Dock folders (customize these to your preferences)
          persistentOthers = [
            "/Users/jrudnik/Downloads"            # Downloads folder
            "/Users/jrudnik/Documents"			# Documents folder
            "/Users/jrudnik/Projects"				# Projects Folder
          ];
        };
        
        # Mission Control settings
        missionControl = {
          exposeAnimation = 0.15;  # Fast Mission Control
        };
        
        # Hot corners for productivity
        hotCorners = {
          topLeft = 1;      # Disabled
          topRight = 1;    # Disabled
          bottomLeft = 1;   # Disabled
          bottomRight = 1;  # Disabled
        };
      };
    };
    
    homebrew = {
      enable = true;
      # Homebrew casks - packages not available or broken in nixpkgs for aarch64-darwin
      casks = [
        "beeper"          # Universal chat client (not in nixpkgs for Apple Silicon)
        "brainfm"         # Focus music app
        "calibre"         # eBook manager (marked broken in nixpkgs)
        "claude"          # Anthropic's Claude Desktop
        "jabref"          # Reference manager (not in nixpkgs for Apple Silicon)
        "nimble-commander" # Dual-pane file manager
      ];
    };
    
    theming = {
      enable = true;
      # Start with dark theme - Stylix will auto-adapt to system appearance
      colorScheme = "gruvbox-material-dark-medium";
      polarity = "either"; # Essential: Enables automatic light/dark switching
      
      # Enable automatic light/dark theme switching
      autoSwitch = {
        enable = true;
        lightScheme = "gruvbox-material-light-medium";
        darkScheme = "gruvbox-material-dark-medium";
      };
      
      # Optional: Set a wallpaper to generate colors from
      # wallpaper = ./wallpapers/your-wallpaper.jpg;
      
      # Easy color scheme alternatives to try:
      # For catppuccin: lightScheme = "catppuccin-latte", darkScheme = "catppuccin-mocha"
      # For tokyo-night: lightScheme = "tokyo-night-light", darkScheme = "tokyo-night-dark"
      # For github: lightScheme = "github", darkScheme = "github-dark"
    };
    
    fonts = {
      enable = true;
      # iM-Writing Nerd Font as default (iA Writer aesthetic + icons)
      # Multiple Nerd Fonts installed: FiraCode, JetBrains Mono, Hack, etc.
      # iA Writer fonts and Charter serif also available
    };
    raycast = {
      enable = true;
    };
    
  };
}
