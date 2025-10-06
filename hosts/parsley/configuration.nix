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

  # Host identification
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
      
      # Enhanced dock configuration with snappy behavior
      dock = {
        autohide = true;
        autohideDelay = 0.0;  # Instant response
        autohideTime = 0.15;  # Quick animation
        orientation = "left";  # Left-side dock for better screen usage
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
          topRight = 11;    # Launchpad
          bottomLeft = 1;   # Disabled
          bottomRight = 2;  # Mission Control
        };
        
        # Performance optimizations
        exposeAnimation = 0.15;  # Fast Mission Control
        launchanim = true;  # Keep app launch animation
        showProcessIndicators = true;  # Show running app indicators
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
      # Uses Gruvbox Material with auto light/dark switching
      colorScheme = "gruvbox-material-dark-medium";
      polarity = "either"; # Allows automatic light/dark switching
      
      # Optional: Set a wallpaper to generate colors from
      # wallpaper = ./wallpapers/your-wallpaper.jpg;
      
      # Easy color scheme alternatives to try:
      # colorScheme = "gruvbox-material-light-medium";  # Light version
      # colorScheme = "catppuccin-mocha";               # Purple theme
      # colorScheme = "tokyo-night-dark";               # Blue theme  
      # colorScheme = "nord";                           # Cool gray theme
    };
    
    fonts = {
      enable = true;
      # iM-Writing Nerd Font as default (iA Writer aesthetic + icons)
      # Multiple Nerd Fonts installed: FiraCode, JetBrains Mono, Hack, etc.
      # iA Writer fonts and Charter serif also available
    };
    
  };
}
