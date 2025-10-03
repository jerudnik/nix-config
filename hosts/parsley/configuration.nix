{ config, pkgs, lib, inputs, outputs, ... }:

{
  # System identification
  networking = {
    hostName = "parsley";
    computerName = "parsley";
    localHostName = "parsley";
  };

  # System architecture
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Define user
  users.users.jrudnik = {
    name = "jrudnik";
    home = "/Users/jrudnik";
  };

  # Enable flakes and new nix command
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Trusted users for nix operations
      trusted-users = [ "root" "jrudnik" ];
      
      # Additional binary caches for faster builds
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Auto-optimize store to save disk space
      auto-optimise-store = true;
    };
    
    # Garbage collection - enhanced for better cleanup
    gc = {
      automatic = true;
      interval = { Weekday = 7; Hour = 3; Minute = 15; };  # Weekly on Sunday at 3:15 AM
      options = "--delete-older-than 30d";
    };
    
    # Store optimization
    optimise.automatic = true;
  };

  # System packages - keep minimal
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # Shell configuration
  programs = {
    zsh.enable = true;
    bash.completion.enable = true;
  };

  # Security
  security.pam.services.sudo_local.touchIdAuth = true;

  # System defaults
  system = {
    stateVersion = 5;
    
    # Set primary user for system-wide user defaults
    primaryUser = "jrudnik";
    
    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        orientation = "bottom";
        show-recents = false;
      };
      
      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      
      # Global settings
      NSGlobalDomain = {
        # Disable automatic capitalization and correction
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        
        # Expand save and print panels by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };
    };
  };
}