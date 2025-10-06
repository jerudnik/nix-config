{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.starship;
in {
  options.home.starship = {
    enable = mkEnableOption "Starship cross-shell prompt";
    
    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh integration for starship";
      example = true;
    };
    
    theme = mkOption {
      type = types.enum [ "gruvbox-rainbow" "minimal" "nerd-font-symbols" ];
      default = "gruvbox-rainbow";
      description = "Starship theme configuration";
      example = "gruvbox-rainbow";
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

  config = mkIf cfg.enable {
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