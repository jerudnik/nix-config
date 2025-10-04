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
      replaceSpotlight = mkOption {
        type = types.bool;
        default = true;
        description = "Replace macOS Spotlight with Raycast (disables Cmd+Space for Spotlight)";
      };
    };
  };
  
  config = mkIf cfg.enable {
    # Install Raycast if enabled
    home.packages = with pkgs; []
      ++ optional cfg.raycast.enable cfg.raycast.package;
    
    # Disable Spotlight shortcut when replacing with Raycast
    # This uses the targets.darwin.defaults system to set macOS defaults
    targets.darwin.defaults = mkIf (cfg.raycast.enable && cfg.raycast.replaceSpotlight) {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Disable "Show Spotlight search" (Cmd+Space)
          "64" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1048576 ];
              type = "standard";
            };
          };
          # Disable "Show Finder search window" (Cmd+Option+Space) 
          "65" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1572864 ];
              type = "standard";
            };
          };
        };
      };
    };
    
    # Launch Raycast at login and set up hotkey
    launchd.agents.raycast = mkIf cfg.raycast.enable {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.raycast.package}/Applications/Raycast.app/Contents/MacOS/Raycast" ];
        RunAtLoad = true;
        KeepAlive = false;
        ProcessType = "Interactive";
      };
    };
    
    # Create setup scripts for Raycast configuration
    home.file.".config/raycast/setup-raycast.sh" = mkIf cfg.raycast.enable {
      executable = true;
      text = ''
        #!/bin/bash
        # Raycast Setup Script
        # This script helps configure Raycast after installation
        
        echo "Setting up Raycast configuration..."
        
        # Create Raycast config directory if it doesn't exist
        mkdir -p ~/Library/Preferences/com.raycast.macos
        
        # Note: Raycast's hotkey configuration is typically done through the UI
        # The system hotkey (Cmd+Space) is disabled via macOS defaults above
        
        echo "Setup complete! Please:"
        echo "1. Launch Raycast and go to Preferences > General"
        echo "2. Set the Raycast Hotkey to 'Command + Space'"
        echo "3. Raycast should now replace Spotlight as your default launcher"
        echo "4. Logout and login again to ensure hotkey changes take effect"
      '';
    };
    
    # Create a script to help with Raycast setup
    home.file.".config/raycast/setup-guide.md" = mkIf cfg.raycast.enable {
      text = ''
        # Raycast Setup Guide

        Raycast has been installed via Nix and configured to replace Spotlight!

        ## Automatic Configuration Done
        ✅ Raycast installed as Home Manager package
        ${optionalString cfg.raycast.replaceSpotlight "✅ macOS Spotlight Cmd+Space shortcut disabled"}
        ✅ Raycast configured to launch at login
        ✅ Setup script created at ~/.config/raycast/setup-raycast.sh

        ## Manual Steps Required
        1. **Launch Raycast** - It should auto-start, or open from Applications
        2. **Set Hotkey** - Go to Raycast Preferences > General > Raycast Hotkey
        3. **Set to Cmd+Space** - This will now work since Spotlight is disabled
        4. **Grant Permissions** - Allow accessibility and other permissions when prompted
        5. **Logout/Login** - For hotkey changes to fully take effect

        ## Integration with nix-darwin Apps
        Raycast will automatically detect applications from:
        - Home Manager (~/Applications/home-manager/)
        - nix-darwin system packages (~/Applications/nix-darwin/)
        - Homebrew casks
        - Standard macOS applications

        ## Troubleshooting
        If Raycast doesn't find your Nix apps:
        1. Run: spotlight-reindex (reindex Spotlight database)
        2. Restart Raycast
        3. Check app folder symlinks in ~/Applications/
        
        If Cmd+Space doesn't work:
        1. Run: ~/.config/raycast/setup-raycast.sh
        2. Logout and login again
        3. Check System Preferences > Keyboard > Shortcuts > Spotlight

        ## Files Created
        - Setup guide: ~/.config/raycast/setup-guide.md
        - Setup script: ~/.config/raycast/setup-raycast.sh (executable)
      '';
    };
  };
}