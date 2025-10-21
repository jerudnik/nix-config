# Starship Aggregator Module
# This module provides an abstract interface for cross-shell prompt configuration.
# It defines "what" starship does without specifying "how" it's implemented.
# Implementation is delegated to backend modules (e.g., starship-native.nix).

{ config, lib, ... }:

with lib;

let
  cfg = config.home.starship;
in {
  imports = [
    ./starship-native.nix  # Home-manager native starship implementation backend
  ];

  options.home.starship = {
    enable = mkEnableOption "Starship cross-shell prompt";
    
    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh integration for starship";
      example = true;
    };
    
    preset = mkOption {
      type = types.enum [ "powerline" "minimal" ];
      default = "powerline";
      description = ''
        Starship prompt layout preset.
        This controls the format and structure of your prompt, NOT colors.
        Colors are automatically sourced from Stylix and adapt to light/dark mode.
        
        - "powerline": Multi-section prompt with arrow separators (inspired by vim-powerline)
        - "minimal": Clean, simple prompt with minimal visual elements
      '';
      example = "powerline";
    };
    
    showLanguages = mkOption {
      type = types.listOf types.str;
      default = [ "nodejs" "rust" "golang" "python" "nix_shell" ];
      description = "List of programming languages to show in prompt";
      example = [ "nodejs" "rust" "python" ];
    };
    
    showSystemInfo = mkOption {
      type = types.bool;
      default = true;
      description = "Show system information (OS, username, hostname)";
      example = false;
    };
    
    showTime = mkOption {
      type = types.bool;
      default = true;
      description = "Show current time in prompt";
      example = false;
    };
    
    showBattery = mkOption {
      type = types.bool;
      default = true;
      description = "Show battery status (laptops only)";
      example = false;
    };
    
    cmdDurationThreshold = mkOption {
      type = types.int;
      default = 4000;
      description = "Minimum command duration (ms) to display execution time";
      example = 2000;
    };
  };

  # No config section here - all implementation is delegated to backend modules
  # Backend modules (like starship-native.nix) will implement the actual prompt configuration logic
}