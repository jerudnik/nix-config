# Desktop & Dock System Settings Pane
# This file defines OPTIONS ONLY for the Desktop & Dock settings pane.
# The actual configuration is implemented in the parent default.nix aggregator.

{ lib, ... }:

with lib;

{
  options.darwin.system-settings.desktopAndDock = {
    # Dock behavior
    dock = {
      autohide = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically hide the dock";
      };
      
      autohideDelay = mkOption {
        type = types.float;
        default = 0.0;
        example = 0.5;
        description = "Delay before dock autohide starts (in seconds). 0.0 = instant.";
      };
      
      autohideTime = mkOption {
        type = types.float;
        default = 0.15;
        example = 0.5;
        description = "Duration of dock autohide animation (in seconds). Lower = faster.";
      };
      
      orientation = mkOption {
        type = types.enum [ "bottom" "left" "right" ];
        default = "bottom";
        description = "Dock orientation";
      };
      
      showRecents = mkOption {
        type = types.bool;
        default = false;
        description = "Show recent applications in dock";
      };
      
      magnification = mkOption {
        type = types.bool;
        default = true;
        description = "Enable dock icon magnification on hover";
      };
      
      tileSize = mkOption {
        type = types.int;
        default = 45;
        example = 64;
        description = "Size of dock icons in pixels";
      };
      
      largeSize = mkOption {
        type = types.int;
        default = 70;
        example = 128;
        description = "Size of magnified dock icons in pixels";
      };
      
      mineffect = mkOption {
        type = types.enum [ "genie" "scale" "suck" ];
        default = "scale";
        description = "Minimize window effect";
      };
      
      minimizeToApp = mkOption {
        type = types.bool;
        default = true;
        description = "Minimize windows into their application icon";
      };
      
      showProcessIndicators = mkOption {
        type = types.bool;
        default = true;
        description = "Show indicator lights for open applications";
      };
      
      launchanim = mkOption {
        type = types.bool;
        default = true;
        description = "Animate opening applications from dock";
      };
      
      persistentApps = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [
          "/Applications/Zen.app"
          "/System/Applications/Messages.app"
          "/Applications/VS Code.app"
        ];
        description = "List of application paths to keep in dock";
      };
      
      persistentOthers = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [
          "/Users/jrudnik/Downloads"
          "/Users/jrudnik/Documents"
        ];
        description = "List of folder paths to keep in dock";
      };
    };
    
    # Mission Control settings
    missionControl = {
      separateSpaces = mkOption {
        type = types.bool;
        default = true;
        description = "Displays have separate Spaces (improves multi-monitor workflow)";
      };
      
      exposeAnimation = mkOption {
        type = types.float;
        default = 0.15;
        example = 0.5;
        description = "Duration of Mission Control animation (in seconds)";
      };
    };
    
    # Hot Corners
    hotCorners = {
      topLeft = mkOption {
        type = types.int;
        default = 1;
        example = 5;
        description = ''Top-left hot corner action.
          0=no-op, 2=Mission Control, 3=Application Windows, 4=Desktop,
          5=Start Screen Saver, 6=Disable Screen Saver, 10=Put Display to Sleep,
          11=Launchpad, 12=Notification Center, 13=Lock Screen'';
      };
      
      topRight = mkOption {
        type = types.int;
        default = 11;  # Launchpad
        example = 2;
        description = ''Top-right hot corner action.
          0=no-op, 2=Mission Control, 3=Application Windows, 4=Desktop,
          5=Start Screen Saver, 6=Disable Screen Saver, 10=Put Display to Sleep,
          11=Launchpad, 12=Notification Center, 13=Lock Screen'';
      };
      
      bottomLeft = mkOption {
        type = types.int;
        default = 1;
        example = 4;
        description = ''Bottom-left hot corner action.
          0=no-op, 2=Mission Control, 3=Application Windows, 4=Desktop,
          5=Start Screen Saver, 6=Disable Screen Saver, 10=Put Display to Sleep,
          11=Launchpad, 12=Notification Center, 13=Lock Screen'';
      };
      
      bottomRight = mkOption {
        type = types.int;
        default = 2;  # Mission Control
        example = 12;
        description = ''Bottom-right hot corner action.
          0=no-op, 2=Mission Control, 3=Application Windows, 4=Desktop,
          5=Start Screen Saver, 6=Disable Screen Saver, 10=Put Display to Sleep,
          11=Launchpad, 12=Notification Center, 13=Lock Screen'';
      };
    };
  };
}
