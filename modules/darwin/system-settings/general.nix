# General System Settings Pane
# This file defines OPTIONS ONLY for the General settings pane and related system settings.
# The actual configuration is implemented in the parent default.nix aggregator.
# Includes: text input, save/print panels, Finder preferences
# Note: Most of these write to NSGlobalDomain.

{ lib, ... }:

with lib;

{
  options.darwin.system-settings.general = {
    # Text input settings
    textInput = {
      disableAutomaticCapitalization = mkOption {
        type = types.bool;
        default = true;
        description = "Disable automatic capitalization";
      };
      
      disableAutomaticSpellingCorrection = mkOption {
        type = types.bool;
        default = true;
        description = "Disable automatic spelling correction";
      };
    };
    
    # Save/Print panel settings
    panels = {
      expandSavePanel = mkOption {
        type = types.bool;
        default = true;
        description = "Expand save panels by default";
      };
    };
    
    # Finder settings
    finder = {
      showAllExtensions = mkOption {
        type = types.bool;
        default = true;
        description = "Show all file extensions in Finder";
      };
      
      showPathbar = mkOption {
        type = types.bool;
        default = true;
        description = "Show path bar in Finder";
      };
      
      showStatusBar = mkOption {
        type = types.bool;
        default = true;
        description = "Show status bar in Finder";
      };
      
      defaultViewStyle = mkOption {
        type = types.enum [ "icon" "list" "column" "gallery" ];
        default = "column";
        description = "Default Finder view style";
      };
      
      hideFromDock = mkOption {
        type = types.bool;
        default = false;
        description = "Hide Finder icon from the Dock (Finder still runs in background)";
      };
    };
  };
}
