{ config, pkgs, lib, inputs, outputs, ... }:

{
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

  # GUI Applications - Installed at system level per WARP LAW 4.3
  # "If it has a .app bundle, nix-darwin should install it"
  environment.systemPackages = with pkgs; [
    alacritty
    bitwarden       # Password manager GUI (configuration via home-manager)
    emacs
    warp-terminal
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight
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
    
    system-defaults = {
      enable = true;
      
      # Keyboard settings (moved from home-manager to prevent NSGlobalDomain conflicts)
      globalDomain = {
        keyRepeat = 2;              # Fast key repeat
        initialKeyRepeat = 15;      # Short initial delay
        pressAndHoldEnabled = false; # Disable accent menu, enable key repeat
        keyboardUIMode = 3;         # Full keyboard access
      };
      
      # Enhanced dock configuration with snappy behavior
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
        
        # Hot corners for productivity
        hotCorners = {
          topLeft = 1;      # Disabled
          topRight = 1;    # Disabled
          bottomLeft = 1;   # Disabled
          bottomRight = 1;  # Disabled
        };
        
        # Performance optimizations
        exposeAnimation = 0.15;  # Fast Mission Control
        launchanim = true;  # Keep app launch animation
        showProcessIndicators = true;  # Show running app indicators
        
        # Dock applications (customize these to your preferences)
        persistentApps = [
          "/Applications/Nix Apps/Emacs.app"
          "/Applications/Nix Apps/Alacritty.app"
          "/Applications/Nix Apps/Zen Browser (Twilight).app"
          "/System/Applications/Calendar.app"
          "/Applications/Nix Apps/Bitwarden.app"
          "/System/Applications/System Settings.app"
        ];
        
        # Dock folders (customize these to your preferences)
        persistentOthers = [
          "/Users/jrudnik/Downloads"            # Downloads folder
          "/Users/jrudnik/Documents"			# Documents folder
          "/Users/jrudnik/Projects"				# Projects Folder
        ];
      };
    };
    
    keyboard = {
      enable = true;
      # remapCapsLockToControl = true (default)
    };
    
    homebrew = {
      enable = true;
      # Homebrew casks
      casks = [ "claude" ];
    };
    
    window-manager = {
      enable = false;  # Deprecated - now using home-manager aerospace module
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
    
  };
}
