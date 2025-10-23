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
    warp-terminal
    
    # Browsers
    zen-browser
    
    # Communication
    thunderbird     # Email client
    
    # Productivity & Documents
    skimpdf         # PDF reader and note-taker for macOS
    
    # Media & Entertainment
    vlc-bin-universal  # VLC media player (universal binary for macOS)
    psst               # Spotify client
    
    # Security & Privacy
    bitwarden       # Password manager (configuration via home-manager)
    
    # Utilities
    flameshot       # Screenshot tool with annotations
    syncthing       # Continuous file synchronization
    
    # Image processing
    imagemagick     # Image manipulation CLI
  ];

  sops.defaultSopsFile = ./system.enc.yaml;

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
      
      # Appearance Pane - Settings that appear in System Settings > Appearance
      appearance = {
        hideMenuBar = false;  # Keep native macOS menu bar visible
      };
      
      # General Pane - Settings that appear in System Settings > General
      general = {
        finder = {
          hideFromDock = true;  # Hide Finder from Dock (use Nimble Commander instead)
        };
      };
      
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
            "/Applications/Nix Apps/Warp.app"                             # System - AI Terminal
            "/Applications/Nix Apps/Alacritty.app"						  # System - Terminal
            
            # Media & Entertainment
            "/Applications/Brain.fm.app"                                  # Homebrew - Focus music
            "/Applications/Nix Apps/VLC.app"                              # System - Media player
            
            # Research & Documents
            "/Applications/calibre.app"                                   # Homebrew - eBook management
            "/Applications/JabRef.app"                                    # Homebrew - Reference manager
            "/Applications/Nix Apps/Skim.app"                             # Nix - PDF Viewer
            
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
          topRight = 1;     # Disabled
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
      colorScheme = "ia-light";
      polarity = "either"; # Essential: Enables automatic light/dark switching
      
      # Enable automatic light/dark theme switching
      autoSwitch = {
        enable = true;
        lightScheme = "ia-light";
        darkScheme = "ia-dark";
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
      systemPreferences = {
        enableFontSmoothing = true;
        fontSmoothingStyle = "medium";  # Balanced smoothing for Retina displays
      };
    };
    raycast = {
      enable = true;
    };
    
  };
}
