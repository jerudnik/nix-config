# Starship Native Implementation Module
# This module implements prompt configuration using home-manager's native starship program.
# It translates abstract starship options into concrete home-manager starship configuration.

{ config, lib, ... }:

with lib;

let
  cfg = config.home.starship;
  implCfg = cfg.implementation.starship-native;
in {
  options.home.starship.implementation = {
    starship-native = {
      enable = mkEnableOption "Use home-manager native starship program" // {
        default = true;
      };
    };
  };

  config = mkIf (cfg.enable && implCfg.enable) {
    # Configuration validations
    assertions = [
      {
        assertion = cfg.cmdDurationThreshold >= 1000;
        message = "starship.cmdDurationThreshold must be at least 1000ms to avoid performance issues";
      }
      {
        assertion = cfg.cmdDurationThreshold <= 30000;
        message = "starship.cmdDurationThreshold should not exceed 30000ms (30s) for usability";
      }
      {
        assertion = (lib.length cfg.showLanguages) <= 10;
        message = "starship.showLanguages should contain at most 10 languages to avoid prompt clutter";
      }
      {
        assertion = (cfg.theme == "gruvbox-rainbow") -> (config.lib ? stylix);
        message = "starship theme 'gruvbox-rainbow' requires Stylix to be enabled for color support";
      }
    ];
    
    programs.starship = {
      enable = true;
      enableZshIntegration = cfg.enableZshIntegration;
      
      settings = mkMerge [
        # Base configuration
        (import ./base.nix { inherit config lib; })
        
        # Theme-specific settings
        (mkIf (cfg.theme == "gruvbox-rainbow") 
          (import ./themes/gruvbox-rainbow.nix { inherit config lib; }))
        (mkIf (cfg.theme == "minimal") 
          (import ./themes/minimal.nix { inherit config lib; }))
        (mkIf (cfg.theme == "nerd-font-symbols") 
          (import ./themes/nerd-font.nix { inherit config lib; }))
        
        # Language modules
        (import ./modules/languages.nix { 
          inherit config lib; 
          showLanguages = cfg.showLanguages;
        })
        
        # System info module  
        (mkIf cfg.showSystemInfo
          (import ./modules/system.nix { inherit config lib; }))
        
        # Time module
        (mkIf cfg.showTime
          (import ./modules/time.nix { inherit config lib; }))
        
        # Battery module
        (mkIf cfg.showBattery
          (import ./modules/battery.nix { inherit config lib; }))
        
        # Status and performance modules
        (import ./modules/status.nix { 
          inherit config lib; 
          cmdDurationThreshold = cfg.cmdDurationThreshold;
        })
      ];
    };
  };
}
