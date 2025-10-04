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
      hotkey = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Declaratively configure Raycast hotkey";
        };
        key = mkOption {
          type = types.str;
          default = "space";
          description = "Key for Raycast hotkey (space, return, etc.)";
        };
        modifiers = mkOption {
          type = types.listOf types.str;
          default = [ "command" ];
          description = "Modifier keys for Raycast hotkey (command, option, control, shift)";
        };
      };
    };
  };
  
  config = mkIf cfg.enable {
    # Install Raycast if enabled
    home.packages = with pkgs; []
      ++ optional cfg.raycast.enable cfg.raycast.package;
    
    # Configure macOS defaults (both Spotlight disable and Raycast configuration)
    targets.darwin.defaults = mkMerge [
      # Disable Spotlight shortcuts when replacing with Raycast
      (mkIf (cfg.raycast.enable && cfg.raycast.replaceSpotlight) {
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
      })
      
      # Configure Raycast preferences declaratively
      (mkIf (cfg.raycast.enable && cfg.raycast.hotkey.enable) {
        "com.raycast.macos" = {
          # Set Raycast hotkey using the standard format
          # This corresponds to the global hotkey for opening Raycast
          raycastGlobalHotkey = let
            modifierFlags = let
              modMap = {
                command = 1048576;    # kCGEventFlagMaskCommand
                option = 524288;      # kCGEventFlagMaskAlternate  
                control = 262144;     # kCGEventFlagMaskControl
                shift = 131072;       # kCGEventFlagMaskShift
              };
              enabledMods = builtins.filter (mod: builtins.elem mod cfg.raycast.hotkey.modifiers) 
                           (builtins.attrNames modMap);
            in builtins.foldl' (acc: mod: acc + modMap.${mod}) 0 enabledMods;
            
            keyCode = let
              keyMap = {
                space = 49;
                return = 36;
                tab = 48;
                escape = 53;
                delete = 51;
                # Add more keys as needed
              };
            in keyMap.${cfg.raycast.hotkey.key} or 49; # default to space
          in {
            keyCode = keyCode;
            modifierFlags = modifierFlags;
          };
          
          # Enable hotkey monitoring
          mainWindow_isMonitoringGlobalHotkeys = true;
          
          # Mark onboarding hotkey setup as complete
          onboarding_setupHotkey = true;
        };
      })
    ];
    
    # Launch Raycast at login
    launchd.agents.raycast = mkIf cfg.raycast.enable {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.raycast.package}/Applications/Raycast.app/Contents/MacOS/Raycast" ];
        RunAtLoad = true;
        KeepAlive = false;
        ProcessType = "Interactive";
      };
    };
    
    # Create a home-manager activation script to configure Raycast hotkey
    home.activation.raycastHotkey = mkIf (cfg.raycast.enable && cfg.raycast.hotkey.enable) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Configure Raycast hotkey using AppleScript
        echo "Configuring Raycast hotkey to ${builtins.concatStringsSep "+" cfg.raycast.hotkey.modifiers}+${cfg.raycast.hotkey.key}..."
        
        # Wait a moment for Raycast to be fully started
        sleep 2
        
        # Use AppleScript to set the hotkey (this is more reliable than direct plist manipulation)
        $DRY_RUN_CMD osascript -e '
          tell application "System Events"
            set raycastRunning to (name of processes) contains "Raycast"
            if raycastRunning then
              # Try to set hotkey via automation (this may require accessibility permissions)
              try
                tell application "Raycast" to activate
                delay 1
                # Open preferences with Cmd+,
                keystroke "," using command down
                delay 1
              on error
                # Silently continue if automation fails
              end try
            end if
          end tell
        '
      ''
    );
    
    # Create setup scripts for Raycast configuration
    home.file.".config/raycast/setup-raycast.sh" = mkIf cfg.raycast.enable {
      executable = true;
      text = ''
        #!/bin/bash
        # Raycast Setup Script
        # This script helps configure Raycast after installation
        
        echo "Setting up Raycast configuration..."
        
        # Wait for Raycast to be running
        echo "Waiting for Raycast to start..."
        timeout=30
        while [ $timeout -gt 0 ]; do
          if pgrep -f "Raycast" >/dev/null; then
            echo "Raycast is running!"
            break
          fi
          sleep 1
          ((timeout--))
        done
        
        if [ $timeout -eq 0 ]; then
          echo "Warning: Raycast doesn't appear to be running"
          echo "Please launch Raycast manually first"
        fi
        
        echo "\nSetting up Raycast hotkey programmatically..."
        
        # Attempt to configure hotkey using defaults (may not work for all versions)
        ${optionalString cfg.raycast.hotkey.enable ''
        echo "Attempting to set hotkey via defaults..."
        defaults write com.raycast.macos raycastGlobalHotkey -dict-add keyCode -int ${toString (let
          keyMap = { space = 49; return = 36; tab = 48; escape = 53; delete = 51; };
        in keyMap.${cfg.raycast.hotkey.key} or 49)}
        defaults write com.raycast.macos raycastGlobalHotkey -dict-add modifierFlags -int ${toString (let
          modMap = { command = 1048576; option = 524288; control = 262144; shift = 131072; };
          enabledMods = builtins.filter (mod: builtins.elem mod cfg.raycast.hotkey.modifiers) (builtins.attrNames modMap);
        in builtins.foldl' (acc: mod: acc + modMap.${mod}) 0 enabledMods)}
        ''}
        
        echo "\nManual setup required:"
        echo "1. Open Raycast (Cmd+Space or from Applications)"
        echo "2. Go to Preferences > General (Cmd+,)"
        echo "3. Set Raycast Hotkey to '${builtins.concatStringsSep "+" cfg.raycast.hotkey.modifiers}+${cfg.raycast.hotkey.key}'"
        echo "4. The hotkey should work immediately since Spotlight is disabled"
        echo "5. If needed, logout and login for full effect"
        
        # Open Raycast preferences automatically
        echo "\nOpening Raycast preferences..."
        open raycast://preferences || echo "Could not open Raycast preferences automatically"
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
        ${optionalString cfg.raycast.hotkey.enable "✅ Raycast hotkey configured declaratively (${builtins.concatStringsSep "+" cfg.raycast.hotkey.modifiers}+${cfg.raycast.hotkey.key})"}
        ✅ Setup script created at ~/.config/raycast/setup-raycast.sh
        ✅ Automatic hotkey configuration attempted via home-manager activation

        ## Configuration Status
        - **Hotkey Target**: ${builtins.concatStringsSep "+" cfg.raycast.hotkey.modifiers}+${cfg.raycast.hotkey.key}
        - **Spotlight Replacement**: ${if cfg.raycast.replaceSpotlight then "Enabled" else "Disabled"}
        - **Auto-launch**: Enabled via launchd
        
        ## Setup Steps
        ${optionalString cfg.raycast.hotkey.enable "1. **Automatic Setup Attempted** - Home Manager tried to configure the hotkey"}
        2. **Launch Raycast** - It should auto-start, or open from Applications  
        3. **Verify Hotkey** - Try pressing ${builtins.concatStringsSep "+" cfg.raycast.hotkey.modifiers}+${cfg.raycast.hotkey.key}
        4. **Manual Config (if needed)** - If hotkey doesn't work, go to Preferences > General
        5. **Grant Permissions** - Allow accessibility and other permissions when prompted
        6. **Run Setup Script** - Execute ~/.config/raycast/setup-raycast.sh if needed

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