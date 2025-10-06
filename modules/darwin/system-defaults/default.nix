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
      
      exposeAnimation = mkOption {
        type = types.float;
        default = 0.15;
        example = 0.5;
        description = "Duration of Mission Control animation (in seconds)";
      };
      
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
    };
    
    missionControl = {
      separateSpaces = mkOption {
        type = types.bool;
        default = true;
        description = "Displays have separate Spaces (improves multi-monitor workflow)";
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
      
      naturalScrolling = mkOption {
        type = types.bool;
        default = false;
        description = "Enable natural scrolling (reversed scrolling direction)";
      };
      
      automaticSwitchAppearance = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically switch between light and dark mode";
      };
      
      hideMenuBar = mkOption {
        type = types.bool;
        default = false;
        description = "Hide the macOS menu bar";
      };
    };
  };

  config = mkIf cfg.enable {
    # Restart Dock and Finder after system defaults changes
    system.activationScripts.restartDockAndFinder.text = ''
      echo "Restarting Dock and Finder to apply system defaults..."
      killall Dock 2>/dev/null || true
      killall Finder 2>/dev/null || true
    '';
    
    system = {
      stateVersion = 5;
      
      defaults = {
        # Dock configuration
        dock = {
          # Basic behavior
          autohide = cfg.dock.autohide;
          autohide-delay = cfg.dock.autohideDelay;
          autohide-time-modifier = cfg.dock.autohideTime;
          orientation = cfg.dock.orientation;
          show-recents = cfg.dock.showRecents;
          
          # Icon appearance and animation
          magnification = cfg.dock.magnification;
          tilesize = cfg.dock.tileSize;
          largesize = cfg.dock.largeSize;
          mineffect = cfg.dock.mineffect;
          minimize-to-application = cfg.dock.minimizeToApp;
          show-process-indicators = cfg.dock.showProcessIndicators;
          launchanim = cfg.dock.launchanim;
          
          # Mission Control integration
          expose-animation-duration = cfg.dock.exposeAnimation;
          mru-spaces = !cfg.missionControl.separateSpaces;
          
          # Hot corners
          wvous-tl-corner = cfg.dock.hotCorners.topLeft;
          wvous-tr-corner = cfg.dock.hotCorners.topRight;
          wvous-bl-corner = cfg.dock.hotCorners.bottomLeft;
          wvous-br-corner = cfg.dock.hotCorners.bottomRight;
        };
        
        # Finder configuration
        finder = {
          AppleShowAllExtensions = cfg.finder.showAllExtensions;
          ShowPathbar = cfg.finder.showPathbar;
          ShowStatusBar = cfg.finder.showStatusBar;
          FXPreferredViewStyle = 
            if cfg.finder.defaultViewStyle == "icon" then "icnv"
            else if cfg.finder.defaultViewStyle == "list" then "Nlsv"
            else if cfg.finder.defaultViewStyle == "column" then "clmv"
            else "Flwv";  # gallery
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
          
          # Scrolling and interface settings
          "com.apple.swipescrolldirection" = cfg.globalDomain.naturalScrolling;
          AppleInterfaceStyleSwitchesAutomatically = cfg.globalDomain.automaticSwitchAppearance;
          
          # Menu bar visibility
          _HIHideMenuBar = cfg.globalDomain.hideMenuBar;
        };
      };
    };
  };
}