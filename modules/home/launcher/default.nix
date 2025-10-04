{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.launcher;
in {
  options.home.launcher = {
    enable = mkEnableOption "Application launcher";
    
    raycast = {
      enable = mkEnableOption "Raycast launcher" // { default = true; };
      package = mkOption {
        type = types.package;
        default = pkgs.raycast;
        description = "Raycast package to use";
      };
    };
  };
  
  config = mkIf cfg.enable {
    # Install Raycast if enabled
    home.packages = with pkgs; []
      ++ optional cfg.raycast.enable cfg.raycast.package;
    
    # Create a script to help with Raycast setup
    home.file.".config/raycast/setup-guide.md" = mkIf cfg.raycast.enable {
      text = ''
        # Raycast Setup Guide

        Raycast has been installed via Nix! Here's how to set it up:

        ## Initial Setup
        1. Launch Raycast from Spotlight (⌘+Space) or from Applications
        2. Follow the onboarding process
        3. Grant necessary permissions when prompted

        ## Recommended Configuration
        - Set Raycast as your default launcher (replaces Spotlight)
        - Import your existing Spotlight shortcuts
        - Enable clipboard history
        - Set up quicklinks for frequently used sites

        ## Integration with nix-darwin Apps
        Raycast should automatically detect applications installed via:
        - Home Manager (in ~/Applications/home-manager/)
        - nix-darwin system packages (in ~/Applications/nix-darwin/)
        - Homebrew casks

        ## Troubleshooting
        If Raycast doesn't find your Nix apps:
        1. Check that the spotlight module is enabled
        2. Run: spotlight-reindex (alias configured by spotlight module)
        3. Restart Raycast

        ## File Location
        This setup guide is located at: ~/.config/raycast/setup-guide.md
      '';
    };
  };
}