{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.system-defaults;
in {
  options.darwin.system-defaults = {
    enable = mkEnableOption "macOS system defaults and preferences";
    
    dock = {
      autohide = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically hide the dock";
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
    };
    
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
    };
    
    globalDomain = {
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
      
      expandSavePanel = mkOption {
        type = types.bool;
        default = true;
        description = "Expand save panels by default";
      };
    };
  };

  config = mkIf cfg.enable {
    system = {
      stateVersion = 5;
      
      defaults = {
        # Dock configuration
        dock = {
          autohide = cfg.dock.autohide;
          orientation = cfg.dock.orientation;
          show-recents = cfg.dock.showRecents;
        };
        
        # Finder configuration
        finder = {
          AppleShowAllExtensions = cfg.finder.showAllExtensions;
          ShowPathbar = cfg.finder.showPathbar;
          ShowStatusBar = cfg.finder.showStatusBar;
        };
        
        # Global domain settings
        NSGlobalDomain = {
          # Text input settings
          NSAutomaticCapitalizationEnabled = !cfg.globalDomain.disableAutomaticCapitalization;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = !cfg.globalDomain.disableAutomaticSpellingCorrection;
          
          # Panel settings
          NSNavPanelExpandedStateForSaveMode = cfg.globalDomain.expandSavePanel;
          NSNavPanelExpandedStateForSaveMode2 = cfg.globalDomain.expandSavePanel;
          PMPrintingExpandedStateForPrint = cfg.globalDomain.expandSavePanel;
          PMPrintingExpandedStateForPrint2 = cfg.globalDomain.expandSavePanel;
        };
      };
    };
  };
}