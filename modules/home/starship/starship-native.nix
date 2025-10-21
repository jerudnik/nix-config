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
        assertion = config.lib ? stylix;
        message = "Starship requires Stylix to be enabled for color support";
      }
    ];
    
    programs.starship = {
      enable = true;
      enableZshIntegration = cfg.enableZshIntegration;
      
      settings = mkMerge [
        # Base configuration (shared across all presets)
        (import ./base.nix { inherit config lib; })
        
        # Preset-specific layouts
        # These define the FORMAT and STRUCTURE, not colors (colors come from Stylix)
        (mkIf (cfg.preset == "powerline") 
          (import ./presets/powerline.nix { inherit config lib; }))
        (mkIf (cfg.preset == "minimal") 
          (import ./presets/minimal.nix { inherit config lib; }))
      ];
    };
  };
}
