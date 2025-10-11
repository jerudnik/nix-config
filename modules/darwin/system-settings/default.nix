# System Settings Aggregator Module
# This module provides a unified interface for macOS System Settings configuration.
# It's organized by System Settings panes for intuitive configuration.
#
# CRITICAL: This module implements a SINGLE, UNIFIED config block to prevent
# NSGlobalDomain conflicts. Multiple panes write to the same preference domains,
# so all configuration must be centralized here to avoid cache corruption.

{ config, lib, ... }:

with lib;

let
  cfg = config.darwin.system-settings;
in {
  imports = [
    ./desktop-and-dock.nix
    ./keyboard.nix
    ./appearance.nix
    ./trackpad.nix
    ./general.nix
  ];

  options.darwin.system-settings = {
    enable = mkEnableOption "macOS System Settings configuration";
  };

  config = mkIf cfg.enable {
    # Validate keyboard configuration
    assertions = [
      {
        assertion = !(cfg.keyboard.remapCapsLockToControl && cfg.keyboard.remapCapsLockToEscape);
        message = "Cannot remap Caps Lock to both Control and Escape simultaneously";
      }
    ];
    
    # Restart Dock and Finder after system defaults changes
    system.activationScripts.restartDockAndFinder.text = ''
      echo "Restarting Dock and Finder to apply system defaults..."
      killall Dock 2>/dev/null || true
      killall Finder 2>/dev/null || true
    '';
    
    # Critical: Synchronize preferences and manage cfprefsd cache
    # This runs AFTER all preference writes (both nix-darwin and home-manager)
    # to prevent cache corruption that causes System Settings blank panes.
    system.activationScripts.postActivation.text = ''
      echo "Synchronizing macOS preferences..."
      
      # Kill cfprefsd to force cache flush after all writes complete
      echo "Flushing preference cache (cfprefsd)..."
      /usr/bin/killall cfprefsd 2>/dev/null || true
      
      # Wait for cfprefsd to auto-restart
      sleep 2
      
      # Force macOS to reload all preferences without logout
      # This makes changes take effect immediately
      echo "Activating preference changes..."
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
      
      echo "Preferences synchronized successfully"
    '';
    
    # Validate preference file integrity after activation
    system.activationScripts.validatePreferences.text = ''
      echo "Validating preference file integrity..."
      
      # Check GlobalPreferences.plist for corruption
      if ! /usr/bin/plutil -lint ~/.GlobalPreferences.plist > /dev/null 2>&1; then
        echo "WARNING: GlobalPreferences.plist is corrupted!" >&2
        echo "You may need to run: rm ~/.GlobalPreferences.plist and rebuild" >&2
      else
        echo "✓ Preference validation passed"
      fi
    '';
    
    # UNIFIED CONFIG BLOCK
    # All pane settings are applied here in a single, coordinated configuration.
    # This prevents NSGlobalDomain conflicts between multiple modules.
    system = {
      stateVersion = 5;
      
      # Keyboard remapping (from keyboard pane)
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = cfg.keyboard.remapCapsLockToControl;
        remapCapsLockToEscape = cfg.keyboard.remapCapsLockToEscape;
      };
      
      defaults = {
        # ===== Desktop & Dock Pane =====
        dock = {
          # Basic behavior (from desktopAndDock.dock)
          autohide = cfg.desktopAndDock.dock.autohide;
          autohide-delay = cfg.desktopAndDock.dock.autohideDelay;
          autohide-time-modifier = cfg.desktopAndDock.dock.autohideTime;
          orientation = cfg.desktopAndDock.dock.orientation;
          show-recents = cfg.desktopAndDock.dock.showRecents;
          
          # Icon appearance and animation
          magnification = cfg.desktopAndDock.dock.magnification;
          tilesize = cfg.desktopAndDock.dock.tileSize;
          largesize = cfg.desktopAndDock.dock.largeSize;
          mineffect = cfg.desktopAndDock.dock.mineffect;
          minimize-to-application = cfg.desktopAndDock.dock.minimizeToApp;
          show-process-indicators = cfg.desktopAndDock.dock.showProcessIndicators;
          launchanim = cfg.desktopAndDock.dock.launchanim;
          
          # Mission Control integration (from desktopAndDock.missionControl)
          expose-animation-duration = cfg.desktopAndDock.missionControl.exposeAnimation;
          mru-spaces = !cfg.desktopAndDock.missionControl.separateSpaces;
          
          # Hot corners (from desktopAndDock.hotCorners)
          wvous-tl-corner = cfg.desktopAndDock.hotCorners.topLeft;
          wvous-tr-corner = cfg.desktopAndDock.hotCorners.topRight;
          wvous-bl-corner = cfg.desktopAndDock.hotCorners.bottomLeft;
          wvous-br-corner = cfg.desktopAndDock.hotCorners.bottomRight;
          
          # Persistent applications and folders
          persistent-apps = cfg.desktopAndDock.dock.persistentApps;
          persistent-others = cfg.desktopAndDock.dock.persistentOthers;
        };
        
        # ===== General Pane =====
        # Finder configuration (from general.finder)
        finder = {
          AppleShowAllExtensions = cfg.general.finder.showAllExtensions;
          ShowPathbar = cfg.general.finder.showPathbar;
          ShowStatusBar = cfg.general.finder.showStatusBar;
          CreateDesktop = !cfg.general.finder.hideFromDock;  # Hide Finder from Dock
          FXPreferredViewStyle = 
            if cfg.general.finder.defaultViewStyle == "icon" then "icnv"
            else if cfg.general.finder.defaultViewStyle == "list" then "Nlsv"
            else if cfg.general.finder.defaultViewStyle == "column" then "clmv"
            else "Flwv";  # gallery
        };
        
        # ===== NSGlobalDomain (Unified) =====
        # CRITICAL: All settings that write to NSGlobalDomain are centralized here
        # to prevent conflicts between multiple panes (Keyboard, Appearance, Trackpad, General)
        NSGlobalDomain = {
          # Text input settings (from general.textInput)
          NSAutomaticCapitalizationEnabled = !cfg.general.textInput.disableAutomaticCapitalization;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = !cfg.general.textInput.disableAutomaticSpellingCorrection;
          
          # Keyboard settings (from keyboard pane)
          KeyRepeat = cfg.keyboard.keyRepeat;
          InitialKeyRepeat = cfg.keyboard.initialKeyRepeat;
          ApplePressAndHoldEnabled = cfg.keyboard.pressAndHoldEnabled;
          AppleKeyboardUIMode = cfg.keyboard.keyboardUIMode;
          "com.apple.keyboard.fnState" = cfg.keyboard.enableFnKeys;
          
          # Panel settings (from general.panels)
          NSNavPanelExpandedStateForSaveMode = cfg.general.panels.expandSavePanel;
          NSNavPanelExpandedStateForSaveMode2 = cfg.general.panels.expandSavePanel;
          PMPrintingExpandedStateForPrint = cfg.general.panels.expandSavePanel;
          PMPrintingExpandedStateForPrint2 = cfg.general.panels.expandSavePanel;
          
          # Trackpad settings (from trackpad pane)
          "com.apple.swipescrolldirection" = cfg.trackpad.naturalScrolling;
          
          # Appearance settings (from appearance pane)
          AppleInterfaceStyleSwitchesAutomatically = cfg.appearance.automaticSwitchAppearance;
          _HIHideMenuBar = cfg.appearance.hideMenuBar;
        };
      };
    };
  };
}
